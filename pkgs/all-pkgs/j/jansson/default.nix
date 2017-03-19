{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "jansson-2.10";

  src = fetchurl {
    url = "http://www.digip.org/jansson/releases/${name}.tar.gz";
    hashOutput = false;
    multihash = "QmT3RPUpADroQwrkfhmyHJnQghjzYcPnuaJCmU7nCPe5Jn";
    sha256 = "78215ad1e277b42681404c1d66870097a50eb084be9d771b1d15576575cf6447";
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
