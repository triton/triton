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

with {
  inherit (stdenv.lib)
    optionals
    optionalString;
};

stdenv.mkDerivation rec {
  name = "harfbuzz-1.1.3";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/harfbuzz/release/${name}.tar.bz2";
    sha256 = "1xxqshbca83x2ik6rc555xzz0qwyb62aiprgj0p6fclwjyvpqgfr";
  };

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
    "--enable-introspection"
    "--with-glib"
    "--with-gobject"
    "--with-cairo"
    "--with-fontconfig"
    "--with-icu"
    "--with-graphite2"
    "--with-freetype"
    "--without-uniscribe"
    "--without-coretext"
  ];

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
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
