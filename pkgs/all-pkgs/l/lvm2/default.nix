{ stdenv
, fetchurl
, fetchTritonPatch
, gettext
, python3Packages

, dlm_lib
, libaio
, libselinux
, libsepol
, readline
, sanlock
, systemd_lib
, systemd-dummy
, thin-provisioning-tools
, util-linux_lib
}:

let
  baseUrls = [
    "mirror://sourceware/lvm2"
    "mirror://sourceware/lvm2/releases"
  ];

  version = "2.02.181";
in
stdenv.mkDerivation rec {
  name = "lvm2-${version}";

  src = fetchurl {
    urls = map (n: "${n}/LVM2.${version}.tgz") baseUrls;
    hashOutput = false;
    sha256 = "400fead33b3abc2d82bd631b63f644b646e83040699f2e8f91ff5779119bb89e";
  };

  nativeBuildInputs = [
    gettext
    python3Packages.wrapPython
  ];

  buildInputs = [
    dlm_lib
    libaio
    libselinux
    libsepol
    python3Packages.dbus-python
    python3Packages.python
    python3Packages.pyudev
    readline
    sanlock
    systemd_lib
    systemd-dummy
    thin-provisioning-tools
    util-linux_lib
  ];

  pythonPath = [
    python3Packages.dbus-python
    python3Packages.pygobject_nocairo
    python3Packages.pyudev
  ];

  patches = [
    (fetchTritonPatch {
      rev = "4eae3ae85a5e46a689a94e2356547952f922d5c6";
      file = "l/lvm2/0001-Fix-paths.patch";
      sha256 = "8167a0b99e5cdddeb13629b1ceb32d70e9f9d060e6f105f80785f39031925693";
    })
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-pkgconfig"
    "--enable-lvmpolld"
    "--enable-lvmlockd-sanlock"
    "--enable-lvmlockd-dlm"
    "--enable-dmfilemapd"
    "--enable-notify-dbus"
    "--enable-udev_sync"
    "--enable-udev_rules"
    "--disable-udev-rule-exec-detection"  # don't look in /usr
    "--enable-cmdlib"
    "--enable-dbus-service"
    "--enable-write_install"
    "--enable-dmeventd"
    #"--enable-nls"  # Broken and well supported
    "--with-clvmd=none"  # Deprecated
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/lib/systemd/system"
      "--with-udevdir=$out/lib/udev/rules.d"
    )
  '';

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "confdir=$out/etc/lvm"
      "SYSTEMD_GENERATOR_DIR=$out/lib/systemd/system-generators"
    )
  '';

  installTargets = [
    "install"
    "install_systemd_generators"
    "install_systemd_units"
    "install_all_man"
    "install_tmpfiles_configuration"
  ];

  # Metad is deprecated
  postInstall = ''
    rm "$out"/lib/udev/rules.d/69-dm-lvm-metad.rules
  '';

  preFixup = ''
    wrapPythonPrograms "$out"/bin

    ! grep -r '/usr' "$out"
    ! grep -r '"/\(sbin\|bin\|libexec\)' "$out"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      sha512Urls = map (n: "${n}/sha512.sum") baseUrls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        "8843 7EF5 C077 BD11 3D3B  7224 2281 91C1 567E 2C17"
        # Marian Csontos
        "D501 A478 440A E2FD 130A  1BE8 B911 2431 E509 039F"
      ];
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
