{ stdenv
, fetchurl
, fetchTritonPatch
, lib
, gettext
, python3Packages

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

  version = "2.03.09";
in
stdenv.mkDerivation rec {
  name = "lvm2-${version}";

  src = fetchurl {
    urls = map (n: "${n}/LVM2.${version}.tgz") baseUrls;
    hashOutput = false;
    sha256 = "c03a8b8d5c03ba8ac54ebddf670ae0d086edac54a6577e8c50721a8e174eb975";
  };

  nativeBuildInputs = [
    gettext
    python3Packages.wrapPython
  ];

  buildInputs = [
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
      rev = "f9edb101b45893496d9b3e7df10a7dea184bd0b2";
      file = "l/lvm2/0001-Fix-paths.patch";
      sha256 = "65c7a2e3c15ac0a658588b45611aea84428c6aa6ccdbf2b9dc594f54dc9a8190";
    })
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-pkgconfig"
    "--enable-lvmpolld"
    "--enable-lvmlockd-sanlock"
    #"--enable-lvmlockd-dlm"  # TODO: Not fully built
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

  preFixup = ''
    wrapPythonPrograms "$out"/bin

    ! grep -r '/usr' "$out"
    ! grep -r '"/\(sbin\|bin\|libexec\)' "$out"


    grep -q "$out/bin/systemd-run" "$out"/lib/udev/rules.d/69-dm-lvm-metad.rules
    sed -i "s,$out/bin/systemd-run,/run/current-system/sw/bin/systemd-run," \
      "$out"/lib/udev/rules.d/69-dm-lvm-metad.rules
    ! grep -r "$out/bin/system.*" "$out"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha512Urls = map (n: "${n}/sha512.sum") baseUrls;
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprints = [
          "8843 7EF5 C077 BD11 3D3B  7224 2281 91C1 567E 2C17"
          # Marian Csontos
          "D501 A478 440A E2FD 130A  1BE8 B911 2431 E509 039F"
        ];
      };
    };
  };

  meta = with lib; {
    homepage = http://sourceware.org/lvm2/;
    descriptions = "Tools to support Logical Volume Management (LVM) on Linux";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
