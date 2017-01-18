{ stdenv
, autoconf
, automake
, fetchFromGitHub
, fetchTritonPatch
, libtool
, nukeReferences

, util-linux_full
, zlib
, attr
, python
, systemd_lib
, lvm2

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
    versionOlder;

  buildKernel = any (n: n == type) [ "kernel" "all" ];
  buildUser = any (n: n == type) [ "user" "all" ];

  source = (import ./sources.nix)."${channel}";

  version = if source ? version then source.version else source.date;
in

assert any (n: n == type) [ "kernel" "user" "all" ];
assert buildKernel -> kernel != null && spl != null;

assert spl != null -> spl.buildType == type;

assert kernel != null -> versionOlder kernel.version source.maxKernelVersion
  || throw "SPL ${version} is too old for kernel ${kernel.version}";

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
      rev = "d64b243a7e8d59afda1abed661e1e79bef8fb705";
      file = "z/zfs/0001-Fix-makefile-paths.patch";
      sha256 = "d9ca26707232a489e0a27baec5d723fd04658f11f9d4eafc64981de8a57b3613";
    })
    (fetchTritonPatch {
      rev = "d64b243a7e8d59afda1abed661e1e79bef8fb705";
      file = "z/zfs/0002-Fix-binary-paths.patch";
      sha256 = "d78de0db7a777981f861d3765a20e3c9b8d9145c782617e275787455739da65f";
    })
  ] ++ optionals (channel == "dev") [
    (fetchTritonPatch {
      rev = "7a56edd41ce78feba009a15303b0295bf07026c6";
      file = "z/zfs/0001-Fix-makefile-paths.patch";
      sha256 = "ff8583179901acc8315209c9546f0e930a9fc9c21de71cec5569968fddc11829";
    })
    (fetchTritonPatch {
      rev = "7a56edd41ce78feba009a15303b0295bf07026c6";
      file = "z/zfs/0002-Fix-binary-paths.patch";
      sha256 = "01346dda86ce17b6d4a2ba7b3d56efdaf466c73d0e793e0875d166821fa4b2de";
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
