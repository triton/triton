{ stdenv
, fetchurl

, alsa-lib
, dbus
, ell
, glib
, json-c
, libical
, readline
, systemd_lib
}:

let
  baseUrl = "mirror://kernel/linux/bluetooth";
in
stdenv.mkDerivation rec {
  name = "bluez-5.50";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "5ffcaae18bbb6155f1591be8c24898dc12f062075a40b538b745bfd477481911";
  };

  buildInputs = [
    alsa-lib
    dbus
    ell
    glib
    json-c
    libical
    readline
    systemd_lib
  ];

  preConfigure = ''
    grep -q '"/sbin/udevadm' tools/hid2hci.rules
    sed -i tools/hid2hci.rules \
      -e 's,/sbin/udevadm,${systemd_lib}/bin/udevadm,' \
      -e 's,hid2hci ,$out/lib/udev/hid2hci ,'

    configureFlagsArray+=(
      "--with-dbusconfdir=$out/etc"
      "--with-dbussystembusdir=$out/share/dbus-1/system-services"
      "--with-dbussessionbusdir=$out/share/dbus-1/services"
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
      "--with-systemduserunitdir=$out/etc/systemd/user"
      "--with-udevdir=$out/lib/udev"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-pie"
    "--enable-threads"
    "--enable-library"
    "--enable-nfc"
    "--enable-sap"
    "--enable-health"
    "--enable-mesh"
    "--enable-midi"
    "--enable-btpclient"
    "--enable-manpages"
    "--enable-sixaxis"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrl = "${baseUrl}/${name}.tar.sign";
        pgpDecompress = true;
        pgpKeyFingerprint = "E932 D120 BC2A EC44 4E55  8F01 06CA 9F5D 1DCF 2659";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Bluetooth support for Linux";
    homepage = http://www.bluez.org/;
    license = with licenses; [
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
