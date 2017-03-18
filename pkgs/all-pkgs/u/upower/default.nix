{ stdenv
, docbook-xsl
, gettext
, fetchurl
, intltool
, lib
, libxslt

, dbus-glib
, glib
, libgudev
, libimobiledevice
, libplist
, libusb
, systemd_lib
, gobject-introspection
}:

let
  inherit (lib)
    boolEn
    boolWt;
in
stdenv.mkDerivation rec {
  name = "upower-0.99.4";

  src = fetchurl {
    url = "https://upower.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "9ca325a6ccef505529b268ebbbd9becd0ce65a65f6ac7ee31e2e5b17648037b0";
  };

  nativeBuildInputs = [
    docbook-xsl
    gettext
    intltool
    libxslt
  ];

  buildInputs = [
    dbus-glib
    glib
    gobject-introspection
    libgudev
    libusb
    systemd_lib
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-udevrulesdir=$out/lib/udev/rules.d"
      "--with-systemdutildir=$out/lib/systemd"
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
    )
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-maintainer-mode"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-deprecated"
    "--enable-manpages"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-tests"
    "--enable-nls"
    "--with-backend=linux"
    "--${boolWt (libimobiledevice != null && libplist != null)}-idevice"
  ];

  NIX_LDFLAGS = [
    "-lgcc_s"
  ];

  preInstall = ''
    installFlagsArray+=(
      "historydir=$TMPDIR"
      "sysconfdir=$out/etc"
    )
  '';

  meta = with lib; {
    description = "A D-Bus service for power management";
    homepage = https://upower.freedesktop.org/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
