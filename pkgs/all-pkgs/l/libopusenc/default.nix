{ stdenv
, fetchurl
, lib

, libogg
, openssl
, opus
}:

stdenv.mkDerivation rec {
  name = "libopusenc-0.2.1";

  src = fetchurl {
    url = "mirror://xiph/opus/${name}.tar.gz";
    multihash = "QmRnDTz5mcfmXUBBZ53ZUstPy44k7YJwLJUrtUXVzEg2NX";
    hashOutput = false;
    sha256 = "8298db61a8d3d63e41c1a80705baa8ce9ff3f50452ea7ec1c19a564fe106cbb9";
  };

  buildInputs = [
    #libogg
    #openssl
    opus
  ];

  configureFlags = [
    "--disable-maintainer-mode"
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

  meta = with lib; {
    homepage = http://www.opus-codec.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
