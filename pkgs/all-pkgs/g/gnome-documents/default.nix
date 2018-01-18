{ stdenv
, docbook-xsl
, fetchurl
, intltool
, itstool
, libxslt
, makeWrapper

, adwaita-icon-theme
, atk
, clutter
, clutter-gtk
, dconf
, desktop_file_utils
, evince
, gdk-pixbuf
, gjs
, glib
, gmp
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

, channel
}:

let
  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-documents-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-documents/${channel}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/gnome-documents/${channel}/"
      + "${name}.sha256sum";
    sha256 = "c73810ded97431360ba80c127d3244b1e6e416643fba0ba96411d22729211394";
  };

  nativeBuildInputs = [
    docbook-xsl
    intltool
    itstool
    libxslt
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    clutter
    clutter-gtk
    dconf
    desktop_file_utils
    evince
    gdk-pixbuf
    gjs
    glib
    gmp
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
    wrapProgram $out/bin/gnome-documents \
      --run 'if [ -z "$XDG_CACHE_DIR" ] ; then XDG_CACHE_DIR=$HOME/.cache ; fi' \
      --run 'if [ -d "$XDG_CACHE_DIR/gnome-documents" ] ; then mkdir -p "$XDG_CACHE_DIR/gnome-documents" ; fi' \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --set 'LD_PRELOAD' "${gnome-online-accounts}/lib/libgoa-1.0.so" \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A document manager application for GNOME";
    homepage = https://wiki.gnome.org/Apps/Documents;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
