{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "jansson-2.9";

  src = fetchurl {
    url = "http://www.digip.org/jansson/releases/${name}.tar.gz";
    hashOutput = false;
    multihash = "QmepVqa6YdvgG8UWmXeSKAoVWEe4cLRqH6zCi72cnFbEsE";
    sha256 = "0ad0d074ca049a36637e7abef755d40849ad73e926b93914ce294927b97bd2a5";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "B5D6 953E 6D50 59ED 7ADA  0F2F D365 7D24 D058 434C";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
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
