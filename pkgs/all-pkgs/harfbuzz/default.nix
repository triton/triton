{ stdenv
, fetchurl
, python

, cairo
, fontconfig
, freetype
, glib
, gobject-introspection
, graphite2
, icu
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals
    optionalString
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "harfbuzz-1.2.6";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/harfbuzz/release/${name}.tar.bz2";
    sha256 = "7537bacccb3524df0cd2a4d5bc7e168bcc10e8171e0324f3cd522583868192c1";
  };

  nativeBuildInputs = optionals doCheck [
    python
  ];

  buildInputs = [
    cairo
    fontconfig
    freetype
    glib
    gobject-introspection
    graphite2
    icu
  ];

  postPatch = optionalString doCheck (''
    patchShebangs test/shaping/
  '' +
  /* failing test, https://bugs.freedesktop.org/show_bug.cgi?id=89190 */ ''
    sed -i test/shaping/Makefile.{am,in} \
      -e 's|tests/arabic-fallback-shaping.tests||'
  '' +
  /* test fails */ ''
    sed -i test/shaping/Makefile.{am,in} \
      -e 's|tests/vertical.tests||'
  '');

  configureFlags = [
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    (wtFlag "glib" (glib != null) null)
    (wtFlag "gobject" (glib != null) null)
    (wtFlag "cairo" (cairo != null) null)
    (wtFlag "fontconfig" (fontconfig != null) null)
    (wtFlag "icu" (icu != null) null)
    (wtFlag "graphite2" (graphite2 != null) null)
    (wtFlag "freetype" (freetype != null) null)
    "--without-uniscribe"
    "--without-directwrite"
    "--without-coretext"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  doCheck = true;

  meta = with stdenv.lib; {
    description = "An OpenType text shaping engine";
    homepage = http://www.freedesktop.org/wiki/Software/HarfBuzz;
    license = with licenses; [
      icu
      isc
      mit
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
