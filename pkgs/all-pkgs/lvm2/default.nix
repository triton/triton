{ stdenv
, fetchurl

, coreutils
, readline
, systemd_lib
, util-linux_full
, util-linux_lib
}:

let
  baseUrls = [
    "ftp://sources.redhat.com/pub/lvm2/releases"
  ];
in
stdenv.mkDerivation rec {
  name = "lvm2-${version}";
  version = "2.02.150";

  src = fetchurl {
    urls = map (n: "${n}/LVM2.${version}.tgz") baseUrls;
    allowHashOutput = false;
    sha512 = "66d1a247170f685c72d91d5fc52a2394ba5d5a477686101b9a472a8ac163813f9c80c0d75e4f29939b16000456263e9191cd294520ab5b320915f23f0797f22e";
  };

  configureFlags = [
    "--enable-udev_rules"
    "--enable-udev_sync"
    "--enable-pkgconfig"
    "--enable-applib"
    "--enable-cmdlib"
    "--enable-dmeventd"
  ];

  buildInputs = [
    readline
    systemd_lib
    util-linux_lib
  ];

  preConfigure = ''
    substituteInPlace scripts/lvmdump.sh \
      --replace /usr/bin/tr ${coreutils}/bin/tr
    substituteInPlace scripts/lvm2_activation_generator_systemd_red_hat.c \
      --replace /usr/sbin/lvm $out/sbin/lvm \
      --replace /usr/bin/udevadm ${systemd_lib}/bin/udevadm

    sed -i /DEFAULT_SYS_DIR/d Makefile.in
    sed -i /DEFAULT_PROFILE_DIR/d conf/Makefile.in
  '';

  # To prevent make install from failing.
  preInstall = ''
    installFlagsArray+=(
      "OWNER="
      "GROUP="
      "confdir=$out/etc"
    )
  '';

  # Install systemd stuff.
  installTargets = [
    "install"
    "install_systemd_generators"
    "install_systemd_units"
    "install_tmpfiles_configuration"
  ];

  postInstall = ''
    substituteInPlace $out/lib/udev/rules.d/13-dm-disk.rules \
      --replace $out/sbin/blkid ${util-linux_full}/bin/blkid

    # Systemd stuff
    mkdir -p $out/etc/systemd/system $out/lib/systemd/system-generators
    cp scripts/blk_availability_systemd_red_hat.service $out/etc/systemd/system
    cp scripts/lvm2_activation_generator_systemd_red_hat $out/lib/systemd/system-generators
  '';

  passthru = {
    srcVerified = fetchurl rec {
      failEarly = true;
      sha512Urls = map (n: "${n}/sha512.sum") baseUrls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "8843 7EF5 C077 BD11 3D3B  7224 2281 91C1 567E 2C17";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://sourceware.org/lvm2/;
    descriptions = "Tools to support Logical Volume Management (LVM) on Linux";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
