{ stdenv
, fetchurl

, libogg
, openssl
, opus
}:

stdenv.mkDerivation rec {
  name = "opusfile-0.10";

  src = fetchurl {
    url = "mirror://xiph/opus/${name}.tar.gz";
    hashOutput = false;
    sha256 = "48e03526ba87ef9cf5f1c47b5ebe3aa195bd89b912a57060c36184a6cd19412f";
  };

  buildInputs = [
    libogg
    openssl
    opus
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-assertions"
    "--enable-http"
    "--enable-fixed-point"
    "--enable-float"
    "--disable-examples"
    "--disable-doc"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha256Url = "mirror://xiph/opus/SHA256SUMS.txt";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "High-level API for decoding and seeking in .opus files";
    homepage = http://www.opus-codec.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
