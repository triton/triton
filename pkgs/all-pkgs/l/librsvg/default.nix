{ stdenv
, fetchurl
, lib

, cairo
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gobject-introspection
, libcroco
, libgsf
, libxml2
, pango
, rustPackages
}:

let
  inherit (lib)
    boolEn;

  channel = "2.44";
  version = "${channel}.13";
in
stdenv.mkDerivation rec {
  name = "librsvg-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/librsvg/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "d2d660bf0c6441d019ae7a7ba96b789facbfb14dc97818908ee03e15ba6bcb8f";
  };

  nativeBuildInputs = [
    rustPackages.cargo
    rustPackages.rustc
  ];

  buildInputs = [
    cairo
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gobject-introspection
    libcroco
    libgsf
    libxml2
    pango
    rustPackages.rust-proc-macro
    rustPackages.rust-std
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-tools"
    "--${boolEn (gobject-introspection != null)}-introspection"
  ];

  # Librsvg updates gdk-pixbuf's loader cache by default, this forces the
  # loaders.cache to be generated into the correct prefix.
  postConfigure = ''
    sed -i gdk-pixbuf-loader/Makefile \
      -e "/\(pkgconfig\|GDK_PIXBUF\)/! s,[^IL]${gdk-pixbuf},$out,g"
  '';

  # We generate loaders.cache in gdk-pixbuf-loaders-cache so this is redundant.
  preFixup = ''
    rm -v $out/${gdk-pixbuf.loadersCachePath}/loaders.cache
  '';

  buildDirCheck = false;  # FIXME

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src) urls outputHash outputHashAlgo;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/librsvg/${channel}/"
          + "${name}.sha256sum";
      };
    };
  };

  meta = with lib; {
    description = "Scalable Vector Graphics (SVG) rendering library";
    homepage = https://wiki.gnome.org/Projects/LibRsvg;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
