{ stdenv
, fetchurl
, gettext
, intltool

, adwaita-icon-theme
, dbus_glib
, dbus_libs
, gcr
, glib
, gnome-common
, gobject-introspection
, gtk3
, icu
, json-glib
, kerberos
, libsecret
, libsoup
, libxml2
, pango
, rest
, telepathy_glib
, webkitgtk
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gnome-online-accounts-${version}";
  versionMajor = "3.18";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-online-accounts/${versionMajor}/${name}.tar.xz";
    sha256 = "09rqdqq0f4p379v1z4fclinghf1sd2kzvgkh3gcgpcgq3a1q7fdz";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-schemas-compile"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-documentation"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-backend"
    "--disable-inspector"
    "--enable-exchange"
    "--enable-flickr"
    "--enable-foursquare"
    "--enable-google"
    "--enable-imap-smtp"
    "--enable-media-server"
    "--enable-owncloud"
    "--enable-facebook"
    "--enable-windows-live"
    "--enable-telepathy"
    "--enable-pocket"
    "--enable-kerberos"
    "--enable-lastfm"
    "--enable-nls"
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${dbus_glib}/include/dbus-1.0"
    "-I${dbus_libs}/include/dbus-1.0"
  ];

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    adwaita-icon-theme
    dbus_glib
    gcr
    glib
    gnome-common
    gobject-introspection
    gtk3
    icu # ???
    json-glib
    kerberos
    libsecret
    libsoup
    libxml2
    rest
    pango
    telepathy_glib
    webkitgtk
    xorg.libX11
  ];

  meta = with stdenv.lib; {
    description = "GNOME framework for accessing online accounts";
    homepage = https://wiki.gnome.org/Projects/GnomeOnlineAccounts;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
