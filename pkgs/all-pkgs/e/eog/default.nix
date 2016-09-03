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

let
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
in

assert xorg != null -> xorg.libX11 != null;

stdenv.mkDerivation rec {
  name = "eog-${version}";
  versionMajor = "3.20";
  versionMinor = "4";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/eog/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/eog/${versionMajor}/${name}.sha256sum";
    sha256 = "968774cc07ea0d3c27ac552dc0f1d51cf682b9036d342b447688a208f31a5be3";
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
    dconf
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
  ] ++ optionals (xorg != null) [
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
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-schemas-compile"
    "--disable-installed-tests"
    (wtFlag "libexif" (libexif != null) null)
    (wtFlag "cms" (xorg != null && lcms2 != null) null)
    (wtFlag "xmp" (exempi != null) null)
    (wtFlag "libjpeg" (libjpeg != null) null)
    (wtFlag "librsvg" (librsvg != null) null)
    (wtFlag "x" (gtk3.x11_backend && xorg != null) null)
  ];

  # Disable -Werror as there are issues with 3.20.2 on gcc 6.1.0
  postPatch = ''
    sed -i 's,-Werror[^ "]*,,g' configure
  '';

  preFixup = ''
    wrapProgram $out/bin/eog \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS" \
      --prefix 'XDG_DATA_DIRS' : "${shared_mime_info}/share"
  '';

  meta = with stdenv.lib; {
    description = "The Eye of GNOME image viewer";
    homepage = https://wiki.gnome.org/Apps/EyeOfGnome;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
