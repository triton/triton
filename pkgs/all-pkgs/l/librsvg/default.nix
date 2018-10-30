{ stdenv
, fetchurl
, lib

, bzip2
, cairo
, fontconfig
, gdk-pixbuf
, glib
, gobject-introspection
, libcroco
, libgsf
, libxml2
, pango
, vala
}:

let
  inherit (lib)
    boolEn;

  channel = "2.40";
  version = "${channel}.20";
in
stdenv.mkDerivation rec {
  name = "librsvg-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/librsvg/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "cff4dd3c3b78bfe99d8fcfad3b8ba1eee3289a0823c0e118d78106be6b84c92b";
  };

  buildInputs = [
    bzip2
    cairo
    fontconfig
    gdk-pixbuf
    glib
    gobject-introspection
    libcroco
    libgsf
    libxml2
    pango
  ];

  configureFlags = [
    "--disable-tools"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-vala"
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
      sha256Url = "https://download.gnome.org/sources/librsvg/${channel}/"
        + "${name}.sha256sum";
      inherit (src) urls outputHash outputHashAlgo;
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
