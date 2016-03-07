{ stdenv
, fetchurl

, dbus
, glib
, libical
, readline
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "bluez-5.37";
   
  src = fetchurl {
    url = "mirror://kernel/linux/bluetooth/${name}.tar.xz";
    sha256 = "c14ba9ddcb0055522073477b8fd8bf1ddf5d219e75fdfd4699b7e0ce5350d6b0";
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
