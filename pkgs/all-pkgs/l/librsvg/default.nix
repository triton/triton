{ stdenv
, fetchurl
, lib

, bzip2
, cairo
, fontconfig
, gdk-pixbuf_unwrapped
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

  versionMajor = "2.40";
  versionMinor = "19";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "librsvg-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/librsvg/${versionMajor}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "612b4d8b8609036f5d899be3fe70d9866b5f6ac5c971154c1c0ef7242216c1f7";
  };

  buildInputs = [
    bzip2
    cairo
    fontconfig
    gdk-pixbuf_unwrapped
    glib
    gobject-introspection
    libcroco
    libgsf
    libxml2
    pango
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-pixbuf-loader"
    "--enable-Bsymbolic"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-tools"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-vala"
  ];

  # Librsvg updates gdk-pixbuf's loader cache by default, this forces the
  # loaders.cache to be generated into the correct prefix.
  postConfigure = ''
    sed -i gdk-pixbuf-loader/Makefile \
      -e "/\(pkgconfig\|GDK_PIXBUF\)/! s,[^IL]${gdk-pixbuf_unwrapped},$out,g"
  '';

  # Prevent the gdk-pixbuf setup-hook from returning the wrong loaders.cache.
  preFixup = ''
    rm -v $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
  '';

  buildDirCheck = false;  # FIXME

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha256Url = "https://download.gnome.org/sources/librsvg/${versionMajor}/"
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
