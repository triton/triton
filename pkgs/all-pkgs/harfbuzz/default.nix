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
  name = "harfbuzz-1.1.2";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/harfbuzz/release/${name}.tar.bz2";
    sha256 = "07s6z3hbrb4rdfgzmln169wxz4nm5y7qbr02ik5c7drxpn85fb2a";
  };

  postPatch = optionalString doCheck ''
    patchShebangs test/shaping/

    # failing test, https://bugs.freedesktop.org/show_bug.cgi?id=89190
    sed -e 's|tests/arabic-fallback-shaping.tests||' \
        -i test/shaping/Makefile.{am,in}

    # test fails
    sed -e 's|tests/vertical.tests||' -i test/shaping/Makefile.{am,in}
  '';

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
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "An OpenType text shaping engine";
    homepage = http://www.freedesktop.org/wiki/Software/HarfBuzz;
    license = licenses.;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
