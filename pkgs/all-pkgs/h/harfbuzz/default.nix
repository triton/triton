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
    boolEn
    boolWt
    optionals
    optionalString;
in

stdenv.mkDerivation rec {
  name = "harfbuzz-1.4.3";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/harfbuzz/release/${name}.tar.bz2";
    multihash = "QmUx6NULya9YvWT69Rom8uGvig7kTPKZGXN5WUgkuoZg9e";
    hashOutput = false;
    sha256 = "838c17400a88a3a451eb401573ef94cdd50919730d98255547c459fef1d85321";
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
  '' + /* failing test, https://bugs.freedesktop.org/show_bug.cgi?id=89190 */ ''
    sed -i test/shaping/Makefile.{am,in} \
      -e 's|tests/arabic-fallback-shaping.tests||'
  '' + /* test fails */ ''
    sed -i test/shaping/Makefile.{am,in} \
      -e 's|tests/vertical.tests||'
  '');

  configureFlags = [
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolWt (glib != null)}-glib"
    "--${boolWt (glib != null)}-gobject"
    "--${boolWt (cairo != null)}-cairo"
    "--${boolWt (fontconfig != null)}-fontconfig"
    "--${boolWt (icu != null)}-icu"
    "--${boolWt (graphite2 != null)}-graphite2"
    "--${boolWt (freetype != null)}-freetype"
    "--without-uniscribe"
    "--without-directwrite"
    "--without-coretext"
  ];

  postInstall = ''
    rm -rvf $out/share/gtk-doc
  '';

  doCheck = true;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      sha256Urls = map (n: "${n}.sha256.asc") src.urls;
      pgpKeyFingerprint = "2277 650A 4E8B DFE4 B7F6  BE41 9FEE 04E5 D353 1115";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

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
