{ stdenv
, fetchurl

, libogg
, openssl
, opus
}:

stdenv.mkDerivation rec {
  name = "opusfile-0.11";

  src = fetchurl {
    url = "mirror://xiph/opus/${name}.tar.gz";
    multihash = "QmcFnKJ373koq45RhrNfF2DauZDPtiSgtaxBXXVGzhc7HB";
    hashOutput = false;
    sha256 = "74ce9b6cf4da103133e7b5c95df810ceb7195471e1162ed57af415fabf5603bf";
  };

  buildInputs = [
    libogg
    openssl
    opus
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-fixed-point"
    "--enable-float"
    "--disable-examples"
    "--disable-doc"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha256Url = "mirror://xiph/opus/SHA256SUMS.txt";
      };
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
