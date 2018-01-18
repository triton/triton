{ stdenv
, fetchurl
, gettext
, intltool
, itstool
, lib
, makeWrapper
# , meson
# , ninja

, adwaita-icon-theme
, atk
, dconf
, exempi
, gdk-pixbuf
, glib
, gnome-desktop
, gobject-introspection
, gsettings-desktop-schemas
, gtk
, lcms2
, libexif
, libjpeg
, libpeas
, librsvg
, libx11
, libxml2
, pango
, shared-mime-info
, zlib

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt
    boolTf
    optionals;

  sources = {
    "3.26" = {
      version = "3.26.2";
      sha256 = "b53e3d4dfa7d0085b829a5fb95f148a099803c00ef276be7685efd5ec38807ad";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "eog-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/eog/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
    itstool
    makeWrapper
    # meson
    # ninja
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
    gtk
    lcms2
    libexif
    libjpeg
    libpeas
    librsvg
    libx11
    libxml2
    pango
    shared-mime-info
    zlib
  ];

  # postPatch = /* handled by setup-hooks */ ''
  #   sed -i meson.build \
  #     -e '/meson_post_install.py/d'
  # '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-debug"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-nls"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-schemas-compile"
    "--disable-installed-tests"
    "--${boolWt (libexif != null)}-libexif"
    "--${boolWt (libx11 != null && lcms2 != null)}-cms"
    "--${boolWt (exempi != null)}-xmp"
    "--${boolWt (libjpeg != null)}-libjpeg"
    "--${boolWt (librsvg != null)}-librsvg"
    "--${boolWt (gtk.x11_backend && libx11 != null)}-x"
  ];

  # mesonFlags = [
  #   "-Dlibexif=${boolTf (libexif != null)}"
  #   "-Dcms=${boolTf (libx11 != null && lcms2 != null)}"
  #   "-Dxmp=${boolTf (exempi != null)}"
  #   "-Dlibjpeg=${boolTf (libjpeg != null)}"
  #   "-Dlibrsvg=${boolTf (librsvg != null)}"
  #   "-Dgtk_doc=false"
  #   "-Dintrospection=${boolTf (gobject-introspection != null)}"
  #   "-Dinstalled_tests=valse"
  # ];

  preFixup = ''
    wrapProgram $out/bin/eog \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/eog/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
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
