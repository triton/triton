{ stdenv
, fetchurl
, lib

, cairo
, glib
, freetype
, gobject-introspection
, lcms2
, libarchive
, libjpeg
, libpng
, libtiff
, zlib

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "libgxps-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgxps/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  buildInputs = [
    cairo
    glib
    freetype
    gobject-introspection
    lcms2
    libarchive
    libjpeg
    libpng
    libtiff
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--enable-cxx-warnings"
    "--disable-iso-cxx"
    "--disable-debug"
    "--disable-test"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-man"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolWt (libjpeg != null)}-libjpeg"
    "--${boolWt (libtiff != null && zlib != null)}-libtiff"
    "--${boolWt (lcms2 != null)}-liblcms2"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libgxps/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Library for handling and rendering XPS documents";
    homepage = https://wiki.gnome.org/Projects/libgxps;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
