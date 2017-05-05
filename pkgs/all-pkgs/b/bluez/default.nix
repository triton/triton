{ stdenv
, fetchurl

, dbus
, glib
, libical
, readline
, systemd_lib
}:

let
  baseUrl = "mirror://kernel/linux/bluetooth";
in
stdenv.mkDerivation rec {
  name = "bluez-5.45";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "4cacb00703a6bc149cb09502257d321597d43952374a16f3558766ffa85364e9";
  };

  buildInputs = [
    dbus
    glib
    libical
    readline
    systemd_lib
  ];

  preConfigure = ''
    sed tools/hid2hci.rules \
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
    "--enable-threads"
    "--enable-library"
    "--disable-test"
    "--enable-tools"
    "--enable-monitor"
    "--enable-udev"
    "--enable-cups"
    "--enable-obex"
    "--enable-client"
    "--enable-systemd"
    "--enable-experimental"
    "--enable-sixaxis"
    "--disable-android"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = "${baseUrl}/${name}.tar.sign";
      pgpDecompress = true;
      pgpKeyFingerprint = "E932 D120 BC2A EC44 4E55  8F01 06CA 9F5D 1DCF 2659";
      inherit (src) urls outputHash outputHashAlgo;
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
