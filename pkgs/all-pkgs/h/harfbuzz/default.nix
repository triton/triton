{ stdenv
, fetchurl
, lib

, cairo
, fontconfig
, freetype_for-harfbuzz
, freetype
, glib
, gobject-introspection
, graphite2
, icu

, type
}:

let
  inherit (lib)
    boolEn
    boolWt
    optionals
    optionalString;

  version = "1.4.7";
in
stdenv.mkDerivation rec {
  name = "harfbuzz-${version}";

  src = fetchurl {
    urls = [
      "https://www.freedesktop.org/software/harfbuzz/release/${name}.tar.bz2"
      ("https://github.com/behdad/harfbuzz/releases/download/${version}/"
        + "${name}.tar.bz2")
    ];
    hashOutput = false;
    sha256 = "b85f6627425d54f32118308e053b939c63a388de9bf455b3830f68cad406bc6d";
  };

  buildInputs = [
    glib
    gobject-introspection
    graphite2
    icu
  ] ++ optionals (type == "lib") [
    freetype_for-harfbuzz
  ] ++ optionals (type == "full") [
    cairo
    fontconfig
    freetype
  ];

  configureFlags = [
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolWt (glib != null)}-glib"
    "--${boolWt (glib != null)}-gobject"
    "--${boolWt (icu != null)}-icu"
    "--${boolWt (graphite2 != null)}-graphite2"
    "--without-uniscribe"
    "--without-directwrite"
    "--without-coretext"
    "--with-freetype"
  ] ++ optionals (type == "full") [
    "--${boolWt (cairo != null)}-cairo"
    "--${boolWt (fontconfig != null)}-fontconfig"
  ];

  postInstall = ''
    rm -rvf $out/share/gtk-doc
  '' + optionalString (type == "lib") ''
    rm -r $out/bin
  '';

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
