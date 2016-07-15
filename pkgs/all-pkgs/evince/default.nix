{ stdenv
, fetchurl
, gettext
, intltool
, itstool
, makeWrapper
, perlPackages

, adwaita-icon-theme
, atk
, cairo
, dconf
, djvulibre
, gdk-pixbuf
, glib
, gnome-desktop
, gobject-introspection
, gsettings-desktop-schemas
, gst-plugins-base
, gst-plugins-good
, gstreamer
, gtk3
, gvfs
, libgxps
, libsecret
, libspectre
, libtiff
, libxml2
, nautilus
, pango
, poppler
, shared_mime_info
, zlib

, python

, recentListSize ? null # 5 is not enough, allow passing a different number
}:

let
  inherit (builtins)
    toString;
  inherit (stdenv.lib)
    enFlag
    optionals
    optionalString
    wtFlag;
in
stdenv.mkDerivation rec {
  name = "evince-${version}";
  versionMajor = "3.20";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/evince/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/evince/${versionMajor}/${name}.sha256sum";
    sha256 = "fc7ac23036939c24f02e9fed6dd6e28a85b4b00b60fa4b591b86443251d20055";
  };

  nativeBuildInputs = [
    gettext
    intltool
    itstool
    makeWrapper
    perlPackages.perl
    perlPackages.XML-Parser
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    cairo
    dconf
    djvulibre
    gdk-pixbuf
    glib
    gnome-desktop
    gobject-introspection
    gsettings-desktop-schemas
    gst-plugins-base
    gst-plugins-good
    gstreamer
    gtk3
    gvfs
    libgxps
    libsecret
    libspectre
    libtiff
    libxml2
    nautilus
    pango
    poppler
    zlib
  ] ++ optionals doCheck [
    python
  ];

  preConfigure =
    optionalString doCheck ''
      for file in test/*.py ; do
        echo "patching $file"
        sed -i "$file" \
          -e '1s,/usr,${python},'
      done
    '' +
    optionalString (recentListSize != null) ''
      sed -i  shell/ev-open-recent-action.c \
        -e 's/\(gtk_recent_chooser_set_limit .*\)5)/\1${toString recentListSize})/'
      sed -i  shell/ev-window.c \
        -e 's/\(if (++n_items == \)5\(.*\)/\1${toString recentListSize}\2/'
    '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-cxx-warnings"
    "--disable-iso-cxx"
    "--enable-nls"
    "--enable-scheams-compile"
    (enFlag "dbus" (glib != null) null)
    "--enable-libgnome-desktop"
    (enFlag "libgnome-desktop" (gnome-desktop != null) null)
    (enFlag "multimedia" (
      gstreamer != null
      && gst-plugins-base != null
      && gst-plugins-good != null) null)
    "--disable-debug"
    (enFlag "nautilus" (
      nautilus != null
      && gtk3 != null
      && glib != null) null)
    "--enable-viewer"
    "--enable-thumbnailer"
    (enFlag "previewer" (
      gtk3 != null
      && glib != null) null)
    (enFlag "browser-plugin" (
      gtk3 != null
      && glib != null) null)
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "pdf" (
      poppler != null
      && libxml2 != null) null)
    (enFlag "ps" (libspectre != null) null)
    (enFlag "tiff" (
      libtiff != null
      && zlib != null) null)
    "--enable-djvu"
    (enFlag "djvu" (djvulibre != null) null)
    # TODO: dvi support (kpathsea)
    "--disable-dvi"
    "--enable-t1lib"
    "--enable-comics"
    (enFlag "xps" (libgxps != null) null)
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--with-platform=gnome"
    (wtFlag "gtk-unix-print" (gtk3 != null) null)
    (wtFlag "keyring" (libsecret != null) null)
  ];

  preFixup = ''
    wrapProgram $out/bin/evince \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'PATH' : "${gvfs}/bin" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS" \
      --prefix 'XDG_DATA_DIRS' : "${shared_mime_info}/share"

    wrapProgram $out/bin/evince-previewer \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --prefix 'PATH' : "${gvfs}/bin" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS" \
      --prefix 'XDG_DATA_DIRS' : "${shared_mime_info}/share"

    wrapProgram $out/bin/evince-thumbnailer \
      --prefix 'PATH' : "${gvfs}/bin" \
      --prefix 'XDG_DATA_DIRS' : "${shared_mime_info}/share"
  '';

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Simple document viewer for GNOME";
    homepage = http://www.gnome.org/projects/evince/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
