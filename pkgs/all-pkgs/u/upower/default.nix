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
  name = "upower-0.99.7";

  src = fetchurl {
    url = "https://upower.freedesktop.org/releases/${name}.tar.xz";
    multihash = "QmcPxNxvv94cTCpmgLpjMWH3wfBZduqaz6jWStUtXfwBYA";
    sha256 = "24bcc2f6ab25a2533bac70b587bcb019e591293076920f5b5e04bdedc140a401";
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
    libimobiledevice
    libusb
    systemd_lib
  ];

  postPatch = /* Fix deprecated libimobiledevice variable */ ''
    sed -i src/linux/up-device-idevice.c \
      -e 's/LOCKDOWN_E_NOT_ENOUGH_DATA/LOCKDOWN_E_RECEIVE_TIMEOUT/'
  '';

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
    "--${boolWt (libimobiledevice != null)}-idevice"
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
