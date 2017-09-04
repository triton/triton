{ stdenv
, autoconf
, automake
, fetchFromGitHub
, fetchTritonPatch
, libtool
, nukeReferences

, attr
, libtirpc
, lvm2
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

assert buildKernel && ! (kernel.isSupportedVersion source.maxLinuxVersion) ->
  throw ("The '${channel}' ZFS channel is only supported on Linux kernel "
    + "channels less than or equal to ${source.maxLinuxVersion}");

stdenv.mkDerivation rec {
  name = "zfs-${type}-${version}${optionalString buildKernel "-${kernel.version}"}";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs";
    rev = "${if source ? version then "zfs-${source.version}" else source.rev}";
    inherit (source) sha256;
    version = source.fetchzipVersion;
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    nukeReferences
  ];

  buildInputs = optionals buildKernel [
    spl
  ] ++ optionals buildUser [
    attr
    libtirpc
    lvm2
    python
    systemd_lib
    util-linux_full
    zlib
  ];

  # for zdb to get the rpath to libgcc_s, needed for pthread_cancel to work
  NIX_CFLAGS_LINK = "-lgcc_s";

  patches = optionals (channel == "stable") [
    (fetchTritonPatch {
      rev = "7ed796b8d2ca1446fc9ca0556f75c99b2a1ff5ef";
      file = "z/zfs/0001-Fix-makefile-paths.patch";
      sha256 = "0f7012f4aea63646ebd4c7624db0e80b871fbd931313794a81326425fcd4bc51";
    })
    (fetchTritonPatch {
      rev = "7ed796b8d2ca1446fc9ca0556f75c99b2a1ff5ef";
      file = "z/zfs/0002-Fix-binary-paths.patch";
      sha256 = "928368e849db348bc17ca8d464bb82fd96ad95b787f1172935c01a46b12127c5";
    })
  ] ++ optionals (channel == "dev") [
    (fetchTritonPatch {
      rev = "4e02a3bc465222d26916d242d048d60fbade872d";
      file = "z/zfs/0001-Fix-makefile-paths.patch";
      sha256 = "50b7de0cd33e9be077877545e7dd2edee8666f15ca0690f4f8c45d53c5e3c482";
    })
    (fetchTritonPatch {
      rev = "4e02a3bc465222d26916d242d048d60fbade872d";
      file = "z/zfs/0002-Fix-binary-paths.patch";
      sha256 = "66510e0620a746e700d481a135b8fc9653fdef88acce5bd82a480962a3cc5b80";
    })
  ];

  postPatch = ''
    sed -i '/INSTALL_MOD_DIR=/a\		INSTALL_MOD_STRIP=1 \\' module/Makefile.in
  '';

  preConfigure = ''
    ./autogen.sh
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
    inherit (source) maxKernelVersion;
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
