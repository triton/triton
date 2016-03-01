{ stdenv
, docbook_xsl
, fetchurl
, intltool
, libxslt

, glib
, dbus_glib
, libgudev
, libusb
, systemd_lib
, gobjectIntrospection
}:

stdenv.mkDerivation rec {
  name = "upower-0.99.4";

  src = fetchurl {
    url = "http://upower.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "1c1ph1j1fnrf3vipxb7ncmdfc36dpvcvpsv8n8lmal7grjk2b8ww";
  };

  nativeBuildInputs = [
    docbook_xsl
    intltool
    libxslt
  ];

  buildInputs = [
    dbus_glib
    libgudev
    libusb
    systemd_lib
    gobjectIntrospection
  ];

  configureFlags = [
    "--with-backend=linux"
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
    "--with-systemdutildir=$(out)/lib/systemd"
    "--with-udevrulesdir=$(out)/lib/udev/rules.d"
  ];

  NIX_CFLAGS_LINK = "-lgcc_s";

  installFlags = "historydir=$(TMPDIR)/foo";

  meta = {
    homepage = http://upower.freedesktop.org/;
    description = "A D-Bus service for power management";
    platforms = stdenv.lib.platforms.linux;
  };
}
