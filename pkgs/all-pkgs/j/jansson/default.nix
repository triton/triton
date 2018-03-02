{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "jansson-2.11";

  src = fetchurl {
    url = "http://www.digip.org/jansson/releases/${name}.tar.gz";
    hashOutput = false;
    multihash = "QmZwCiWdAq19Lygg8Je7J8UX7R1zaB7nYFqM1zX5VaFMFd";
    sha256 = "6e85f42dabe49a7831dbdd6d30dca8a966956b51a9a50ed534b82afc3fa5b2f4";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "B5D6 953E 6D50 59ED 7ADA  0F2F D365 7D24 D058 434C";
      inherit (src) urls outputHash outputHashAlgo;
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
