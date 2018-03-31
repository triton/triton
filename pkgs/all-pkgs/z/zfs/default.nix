{ stdenv
, autoconf
, automake
, elfutils
, fetchFromGitHub
, fetchTritonPatch
, fetchurl
, libtool
, nukeReferences
, perl

, attr
, libtirpc
, lvm2
, openssl
, python
, systemd_lib
, util-linux_full
, zlib

, kernel ? null
, spl ? null

, channel
, type
}:

let
  inherit (stdenv.lib)
    any
    optionals
    optionalString
    versionAtLeast;

  buildKernel = any (n: n == type) [ "kernel" "all" ];
  buildUser = any (n: n == type) [ "user" "all" ];

  source = (import ./sources.nix)."${channel}";

  version = if source ? version then source.version else source.date;
in

assert any (n: n == type) [ "kernel" "user" "all" ];
assert buildKernel -> kernel != null && spl != null;

assert spl != null -> spl.buildType == type;

assert buildKernel && ! (kernel.isCompatibleVersion source.maxLinuxVersion "0") ->
  throw ("The '${channel}' ZFS channel is only supported on Linux kernel "
    + "channels less than or equal to ${source.maxLinuxVersion}");

stdenv.mkDerivation rec {
  name = "zfs-${type}-${version}${optionalString buildKernel "-${kernel.version}"}";

  src = if source ? fetchzipVersion then
    fetchFromGitHub {
      owner = "zfsonlinux";
      repo = "zfs";
      rev = "${if source ? version then "zfs-${source.version}" else source.rev}";
      inherit (source) sha256;
      version = source.fetchzipVersion;
    }
  else
    fetchurl {
      url = "https://github.com/zfsonlinux/zfs/releases/download/zfs-${version}/zfs-${version}.tar.gz";
      inherit (source) sha256;
    };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    nukeReferences
  ] ++ optionals buildKernel [
    elfutils
    perl
  ];

  buildInputs = optionals buildKernel [
    spl
  ] ++ optionals buildUser [
    libtirpc
    lvm2
    python
    systemd_lib
    util-linux_full
    zlib
  ] ++ optionals (buildUser && channel != "dev") [
    attr
  ] ++ optionals (buildUser && channel == "dev") [
    openssl
  ];

  # for zdb to get the rpath to libgcc_s, needed for pthread_cancel to work
  NIX_CFLAGS_LINK = "-lgcc_s";

  patches = optionals (channel == "stable") [
    (fetchTritonPatch {
      rev = "a061e816f5a9fa5565f53a4213edb75b42ee5607";
      file = "z/zfs/0001-Fix-makefile-paths.patch";
      sha256 = "6399efed746a7852059e0cfe40c7201daaf3e78ab71335b641bf9d6dadcbe4c3";
    })
    (fetchTritonPatch {
      rev = "a061e816f5a9fa5565f53a4213edb75b42ee5607";
      file = "z/zfs/0002-Fix-binary-paths.patch";
      sha256 = "a114332256ed06c51c2e9c019f0b810947f65393d5b82bcf1e72b13c351c7fe6";
    })
  ] ++ optionals (channel == "dev") [
    (fetchTritonPatch {
      rev = "655a000510355ec804a48eb01bd3f16f3e9de7c3";
      file = "z/zfs/0001-Fix-makefile-paths.patch";
      sha256 = "311a2c442c8afcf8d43d7ff91a1daff410aa009cefcdc6f1cd92cde8c8e34c21";
    })
    (fetchTritonPatch {
      rev = "655a000510355ec804a48eb01bd3f16f3e9de7c3";
      file = "z/zfs/0002-Fix-binary-paths.patch";
      sha256 = "95c0e2d8a6efbe2e67c654f5756e4f5136e33dd56d32c5a0b6b0dd4df03bedb9";
    })
  ];

  postPatch = ''
    sed -i '/INSTALL_MOD_DIR=/a\		INSTALL_MOD_STRIP=1 \\' module/Makefile.in
  '';

  preConfigure = ''
    ./autogen.sh
  '' + optionalString (buildKernel) ''
    patchShebangs scripts/enum-extract.pl
  '' + optionalString buildUser ''
    configureFlagsArray+=(
      "--with-dracutdir=$out/lib/dracut"
      "--with-udevdir=$out/lib/udev"
      "--with-systemdunitdir=$out/etc/systemd/system"
      "--with-systemdpresetdir=$out/etc/systemd/system-preset"
      "--with-systemdmodulesloaddir=$out/etc/module-load.d"
      "--with-mounthelperdir=$out/bin"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-config=${type}"
  ] ++ optionals buildUser [
    "--enable-systemd"
    "--with-tirpc"
  ] ++ optionals buildKernel [
    "--with-spl=${spl}/libexec/spl"
    "--with-linux=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
    "--with-linux-obj=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "DEFAULT_INITCONF_DIR=$out/etc/default"
      "DEFAULT_INIT_DIR=$out/etc/init.d"
    )
  '';

  postInstall = optionalString buildUser ''
    # Remove test code
    rm -r $out/share/zfs
  '';

  # Fix build impurities
  preFixup = ''
    find "$out" -name Module.symvers -exec sed -i "s,$NIX_BUILD_TOP,/no-such-path,g" {} \;
  '';

  # We don't want these compiler security features / optimizations
  # when we are building kernel modules
  optFlags = !buildKernel;
  pie = !buildKernel;
  fpic = !buildKernel;
  noStrictOverflow = !buildKernel;
  fortifySource = !buildKernel;
  stackProtector = !buildKernel;
  optimize = !buildKernel;

  passthru = {
    inherit (source) maxLinuxVersion;
    inherit spl channel;
    buildType = type;
  };

  allowedReferences = if buildKernel then [ ] else null;

  meta = with stdenv.lib; {
    description = "ZFS Filesystem Linux Kernel module";
    homepage = http://zfsonlinux.org/;
    license = licenses.cddl;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
