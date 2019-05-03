{ stdenv
, autoconf
, automake
, fetchFromGitHub
, fetchTritonPatch
, fetchurl
, lib
, libtool
, perl

, elfutils
, python3
, kernel ? null
, spl ? null

, channel
}:

let
  inherit (lib)
    optionals
    optionalString;

  common = (import ./common.nix {
    inherit
      fetchFromGitHub
      fetchTritonPatch
      fetchurl
      stdenv;
  })."${channel}";
in

assert ! (kernel.isCompatibleVersion common.maxLinuxVersion "0") ->
  throw ("The '${channel}' ZFS channel is only supported on Linux kernel "
    + "channels less than or equal to ${common.maxLinuxVersion}");

stdenv.mkDerivation rec {
  name = "zfs-kernel-${common.version or common.date}-${kernel.version}";

  inherit (common) src;

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    perl
  ];

  buildInputs = [
    elfutils
    python3
  ];

  inherit (common) patches;

  postPatch = ''
    # Strip kernel modules
    grep -q 'INSTALL_MOD_DIR=.*\\' module/Makefile.in
    sed -i '/INSTALL_MOD_DIR=/a\		INSTALL_MOD_STRIP=1 \\' module/Makefile.in
  '';

  preConfigure = ''
    test -f configure || ./autogen.sh

    patchShebangs scripts/enum-extract.pl
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-config=kernel"
    "--with-linux=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
    "--with-linux-obj=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "--with-python=3"
  ];

  preInstall = ''
    installFlagsArray+=("INSTALL_MOD_PATH=$out")
  '';

  postInstall = ''
    rm -r "$out"/src
  '';

  # We don't want these compiler security features / optimizations
  # when we are building kernel modules
  optFlags = false;
  pie = false;
  fpic = false;
  noStrictOverflow = false;
  fortifySource = false;
  stackProtector = false;
  optimize = false;

  passthru = {
    inherit (common) maxLinuxVersion;
    inherit spl channel;
  };

  allowedReferences = [ ];

  meta = with lib; {
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
