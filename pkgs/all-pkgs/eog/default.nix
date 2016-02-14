{ stdenv
, fetchurl
, gettext
, intltool
, itstool
, makeWrapper

, adwaita-icon-theme
, atk
, dconf
, exempi
, gdk-pixbuf
, glib
, gnome-desktop
, gobject-introspection
, gsettings-desktop-schemas
, gtk3
, lcms2
, libexif
, libjpeg
, libpeas
, librsvg
, libxml2
, pango
, shared_mime_info
, xorg
}:

with {
  inherit (stdenv.lib)
    wtFlag;
};

assert xorg != null -> xorg.libX11 != null;

stdenv.mkDerivation rec {
  name = "eog-${version}";
  versionMajor = "3.18";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/eog/${versionMajor}/${name}.tar.xz";
    sha256 = "19wkawrcwjjcvlmizkj57qycnbgizhr8ck3j5qg70605d1xb8yvv";
  };

  nativeBuildInputs = [
    gettext
    intltool
    itstool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    exempi
    gdk-pixbuf
    glib
    gnome-desktop
    gobject-introspection
    gsettings-desktop-schemas
    gtk3
    lcms2
    libexif
    libjpeg
    libpeas
    librsvg
    libxml2
    pango
    shared_mime_info
    xorg.libX11
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-debug"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-nls"
    "--enable-schemas-compile"
    "--disable-installed-tests"
    (wtFlag "libexif" (libexif != null) null)
    (wtFlag "cms" (lcms2 != null) null)
    (wtFlag "xmp" (exempi != null) null)
    (wtFlag "libjpeg" (libjpeg != null) null)
    (wtFlag "librsvg" (librsvg != null) null)
    (wtFlag "x" (xorg != null) null)
  ];

  preFixup = ''
    wrapProgram $out/bin/eog \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "${dconf}/lib/gio/modules" \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    description = "The Eye of GNOME image viewer";
    homepage = https://wiki.gnome.org/Apps/EyeOfGnome;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
