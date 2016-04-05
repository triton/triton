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
  name = "bluez-5.39";
   
  src = fetchurl {
    url = "${baseUrl}/${name}.tar.xz";
    allowHashOutput = false;
    sha256 = "21d1bc9150d3576296595217efb98a746b592389d25d5637e8bee5da7272593b";
  };

  buildInputs = [
    dbus
    glib
    libical
    readline
    systemd_lib
  ];

  preConfigure = ''
    substituteInPlace tools/hid2hci.rules --replace /sbin/udevadm ${systemd_lib}/bin/udevadm
    substituteInPlace tools/hid2hci.rules --replace "hid2hci " "$out/lib/udev/hid2hci "
  
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
    sourceTarball = fetchurl {
      pgpsigUrl = "${baseUrl}/${name}.tar.sign";
      pgpDecompress = true;
      pgpKeyId = "1DCF2659";
      pgpKeyFingerprint = "E932 D120 BC2A EC44 4E55  8F01 06CA 9F5D 1DCF 2659";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Bluetooth support for Linux";
    homepage = http://www.bluez.org/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
