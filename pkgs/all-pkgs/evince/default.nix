{ stdenv
, fetchurl
, gettext
, intltool
, itstool
, perl
, perlXMLParser

, adwaita-icon-theme
, atk
, cairo
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

with {
  inherit (builtins)
    toString;
  inherit (stdenv.lib)
    enFlag
    optionals
    optionalString
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "evince-${version}";
  versionMajor = "3.18";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/evince/${versionMajor}/${name}.tar.xz";
    sha256 = "05ybiqniqbn1nr4arksvc11bkb37z17shvhkmgnak0fqairnrba2";
  };

  nativeBuildInputs = [
    gettext
    intltool
    itstool
    perl
    perlXMLParser
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    cairo
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

  #NIX_CFLAGS_COMPILE = "-I${glib}/include/gio-unix-2.0";

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Simple document viewer for GNOME";
    homepage = http://www.gnome.org/projects/evince/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
