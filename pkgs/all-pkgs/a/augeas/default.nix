{ stdenv
, fetchurl

, libxml2
, readline
}:

stdenv.mkDerivation rec {
  name = "augeas-1.10.1";

  src = fetchurl {
    url = "http://download.augeas.net/${name}.tar.gz";
    multihash = "QmRmKKpszor3JyzdawkFJcW7eJnMNB5NpYz9Me29EgEzeT";
    hashOutput = false;
    sha256 = "52db256afab261d31cc147eaa1a71795a5fec59e888dfd0b65a84c7aacd6364d";
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
