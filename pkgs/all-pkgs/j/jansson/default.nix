{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "jansson-2.8";

  src = fetchurl {
    url = "http://www.digip.org/jansson/releases/${name}.tar.gz";
    hashOutput = false;
    multihash = "QmWbiFgbikuSukX5ZkbxDN1ia4waEiZhENTZzHReJSriZt";
    sha256 = "cef2e9e3190ef8b16bfa4c5ccdf131bd460cd1aaf6e6dad9cd84f4b3ab40fb6c";
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
