{ stdenv
, fetchurl

, libxml2
, readline
}:

stdenv.mkDerivation rec {
  name = "augeas-1.7.0";

  src = fetchurl {
    url = "http://download.augeas.net/${name}.tar.gz";
    hashOutput = false;
    multihash = "QmXpQ8CyxXLNDtnPd9QmUwzp1uRdqsXCLkghAMdacgbmMS";
    sha256 = "b9315575d07f7ba28ca2f9f60b4987dfe77b5970c98b59dc6ca7873fc4979763";
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
