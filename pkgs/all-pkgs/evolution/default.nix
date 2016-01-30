{ stdenv
, fetchurl
, intltool
, itstool
, libtool

, adwaita-icon-theme
, bogofilter
, db
, evolution-data-server
, gcr
, gdk-pixbuf
, glib
, gnome-desktop
, gnome-themes-standard
, gsettings-desktop-schemas
, gst-plugins-base
, gstreamer
, gtk3
, gtkhtml
, gtkspell
, highlight
, icu
, libcanberra
, libgdata
, libgweather
, libical
, libnotify
, librsvg
, libsecret
, libxml2
, nspr
, nss
, p11_kit
, procps
, shared_mime_info
, sqlite
, webkitgtk
}:

stdenv.mkDerivation rec {
  name = "evolution-${version}";
  versionMajor = "3.18";
  versionMinor = "4";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/evolution/${versionMajor}/${name}.tar.xz";
    sha256 = "8161a0ebc77e61904dfaca9745595fefbf84d834a07ee1132d1f8d030dabfefb";
  };

  configureFlags = [
    "--disable-spamassassin"
    "--disable-pst-import"
    "--disable-autoar"
    "--disable-libcryptui"
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${nspr}/include/nspr"
    "-I${nss}/include/nss"
    "-I${glib}/include/gio-unix-2.0"
  ];

  propagatedUserEnvPkgs = [
    gnome-themes-standard
  ];

  nativeBuildInputs = [
    intltool
    itstool
    libtool
  ];

  buildInputs = [
    adwaita-icon-theme
    bogofilter
    db
    evolution-data-server
    gcr
    gdk-pixbuf
    glib
    gnome-desktop
    gsettings-desktop-schemas
    gst-plugins-base
    gstreamer
    gtk3
    gtkhtml
    gtkspell
    highlight
    icu
    libcanberra
    libgdata
    libgweather
    libical
    libnotify
    librsvg
    libsecret
    libxml2
    nspr
    nss
    p11_kit
    procps
    shared_mime_info
    sqlite
    webkitgtk
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Integrated mail, calendaring and address book";
    homepage = https://wiki.gnome.org/Apps/Evolution;
    license = licenses.lgpl2Plus;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
