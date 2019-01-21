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
    boolWt
    optionals
    optionalString;

  version = "2.3.0";
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
    sha256 = "3b314db655a41d19481e18312465fa25fca6f63382217f08062f126059f96764";
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
    "--enable-introspection"
    "--with-glib"
    "--with-gobject"
    "--with-icu"
    "--with-graphite2"
    "--with-freetype"
    "--without-uniscribe"
    "--without-directwrite"
    "--without-coretext"
    "--${boolWt (type == "full" && cairo != null)}-cairo"
    "--${boolWt (type == "full" && fontconfig != null)}-fontconfig"
  ];

  preBuild = optionalString (type == "lib") ''
    for file in $(find . -name Makefile); do
      sed -i 's,^\(all\|install\)-am:,\1-oldam:,' "$file"
      echo 'all-am: $(LTLIBRARIES) $(HEADERS) $(pkgconfig_DATA)' >>"$file"
      echo 'install-am:' >>"$file"
      if grep -q 'install-pkgconfigDATA' "$file"; then
        echo 'install-am: install-pkgconfigDATA' >>"$file"
      fi
      sed -n 's,^\(install-.*\(LTLIBRARIES\|HEADERS\)\):.*$,\1,p' "$file" | \
        xargs echo 'install-am:' >>"$file"
    done
  '';

  postInstall = ''
    rm -rvf $out/share/gtk-doc
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha256Urls = map (n: "${n}.sha256.asc") src.urls;
        pgpKeyFingerprint = "2277 650A 4E8B DFE4 B7F6  BE41 9FEE 04E5 D353 1115";
      };
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
