{ stdenv
, fetchurl
, lib
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
  inherit (lib)
    boolEn
    boolWt
    optionals
    optionalString;
in

stdenv.mkDerivation rec {
  name = "harfbuzz-1.4.4";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/harfbuzz/release/${name}.tar.bz2";
    multihash = "QmQzvPnFq6McDHeQGjepEnSw4Mxp1x3Ay9kXdqj1wEAyfq";
    hashOutput = false;
    sha256 = "35d2f8ca476cbbec64ee824eca6b0209ff8db0334990b9f5af893b94f119d255";
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
  '' + /* test fails */ ''
    sed -i test/shaping/Makefile.{am,in} \
      -e 's|tests/fuzzed.tests||'
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

  meta = with lib; {
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
