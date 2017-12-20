{ stdenv
, fetchurl

, libxml2
, readline
}:

stdenv.mkDerivation rec {
  name = "augeas-1.9.0";

  src = fetchurl {
    url = "http://download.augeas.net/${name}.tar.gz";
    multihash = "Qmf8XFGVQZuoRas8Pir6sBiEBfgmMSoJDAYjhxp5dX2GSz";
    hashOutput = false;
    sha256 = "2b463d398cabc9b42747aa61d3e83ed6a93ce03d9074cf8e7a7bd3107a668343";
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
