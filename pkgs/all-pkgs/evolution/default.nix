{ stdenv
, fetchurl
, intltool
, itstool
, libtool
, makeWrapper

, adwaita-icon-theme
, atk
, bogofilter
, cairo

, dconf
, db
, enchant
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
, libsoup
, libxml2
, nspr
, nss
, p11_kit
, procps
, shared_mime_info
, sqlite
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

  propagatedUserEnvPkgs = [
    gnome-themes-standard
  ];

  nativeBuildInputs = [
    intltool
    itstool
    libtool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    bogofilter
    cairo
    dconf
    db
    enchant
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
    libsoup
    libxml2
    nspr
    nss
    p11_kit
    procps
    shared_mime_info
    sqlite
  ];

  configureFlags = [
    "--disable-spamassassin"
    "--disable-pst-import"
    "--disable-autoar"
    "--disable-libcryptui"
  ];

  preFixup = ''
    wrapProgram $out/bin/evolution \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Integrated mail, calendaring and address book";
    homepage = https://wiki.gnome.org/Apps/Evolution;
    license = licenses.lgpl2Plus;
    maintainers = gnome3.maintainers;
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
    # evolution does not support webkit-2.10+
    broken = true;
  };
}
