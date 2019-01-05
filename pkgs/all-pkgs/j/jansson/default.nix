{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "jansson-2.12";

  src = fetchurl {
    url = "http://www.digip.org/jansson/releases/${name}.tar.gz";
    multihash = "QmNY8K99KqYA6UMPJc5RdrQyzRkFYUeVFuLmbiFhUiFXhw";
    hashOutput = false;
    sha256 = "5f8dec765048efac5d919aded51b26a32a05397ea207aa769ff6b53c7027d2c9";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "B5D6 953E 6D50 59ED 7ADA  0F2F D365 7D24 D058 434C";
      };
    };
  };

  meta = with lib; {
    homepage = "http://www.digip.org/jansson/";
    description = "C library for encoding, decoding and manipulating JSON data";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
