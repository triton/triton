{ stdenv
, fetchurl

, libxml2
, readline
}:

stdenv.mkDerivation rec {
  name = "augeas-1.10.0";

  src = fetchurl {
    url = "http://download.augeas.net/${name}.tar.gz";
    multihash = "Qma6ktnHeJtD5rgDKQ25Nj1fXH5JLXe19UTBGpDYWMxPFh";
    hashOutput = false;
    sha256 = "2a90f6984c3cca1e64dfcad3af490f38ae86e2f3510ed9e46a391cd947860213";
  };

  buildInputs = [
    libxml2
    readline
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
