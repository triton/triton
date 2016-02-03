{ stdenv
, docbook_xsl
, fetchurl
, intltool
, itstool
, libxslt

, adwaita-icon-theme
, atk
, desktop_file_utils
, evince
, gdk-pixbuf
, gjs
, glib
, gnome-desktop
, gnome-online-accounts
, gnome-online-miners
, gobject-introspection
, gsettings-desktop-schemas
, gtk3
, inkscape
, json-glib
, libgdata
, libsoup
, libxml2
, libzapojit
, pango
, poppler_utils
, rest
, tracker
, webkitgtk
}:

stdenv.mkDerivation rec {
  name = "gnome-documents-${version}";
  versionMajor = "3.18";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-documents/${versionMajor}/"
        + "${name}.tar.xz";
    sha256 = "1m2clxk54z9ch6vrr3kv725l65mgdyiw6bkcd7hbnjb56vrxl3c5";
  };

  nativeBuildInputs = [
    docbook_xsl
    intltool
    itstool
    libxslt
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    desktop_file_utils
    evince
    gdk-pixbuf
    gjs
    glib
    gnome-desktop
    gnome-online-accounts
    gnome-online-miners
    gobject-introspection
    gsettings-desktop-schemas
    gtk3
    inkscape
    json-glib
    libgdata
    libsoup
    libxml2
    libzapojit
    pango
    poppler_utils
    rest
    tracker
    webkitgtk
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-schemas-compile"
    "--enable-getting-started"
    "--disable-documentation"
  ];

  preFixup = ''
    sed -i $out/bin/gnome-documents \
      -e 's|gapplication|${glib}/bin/gapplication|'

    #gnomeWrapperArgs+=(--run 'if [ -z "$XDG_CACHE_DIR" ]; then XDG_CACHE_DIR=$HOME/.cache; fi; if [ -w "$XDG_CACHE_DIR/.." ]; then mkdir -p "$XDG_CACHE_DIR/gnome-documents"; fi')
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Apps/Documents;
    description = "Document manager application designed to work with GNOME 3";
    maintainers = gnome3.maintainers;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
