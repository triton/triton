{ stdenv
, fetchurl
, lib

, cairo
, libsigcxx
}:

stdenv.mkDerivation rec {
  name = "cairomm-1.12.2";

  src = fetchurl {
    url = "http://cairographics.org/releases/${name}.tar.gz";
    multihash = "QmbiHbZeBhdVb5anjocYxJ9KQQKnZ85PRpDbAnmHRzYx48";
    hashOutput = false;
    sha256 = "45c47fd4d0aa77464a75cdca011143fea3ef795c4753f6e860057da5fb8bd599";
  };

  buildInputs = [
    cairo
    libsigcxx
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-documentation"
    "--enable-warnings"
    "--disable-tests"
    "--enable-api-exceptions"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
    "--without-boost"
    "--without-boost-unit-test-framework"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      sha1Urls = map (n: "${n}.sha1.asc") src.urls;
      pgpKeyFingerprints = [
        # Murray Cumming
        "7835 91DD 0B84 B151 C957  3D66 3B76 CE0E B51B D20A"
      ];
    };
  };

  meta = with lib; {
    description = "C++ bindings for the Cairo vector graphics library";
    homepage = http://cairographics.org/cairomm;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
