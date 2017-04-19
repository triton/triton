{ stdenv
, fetchurl

, libxml2
, readline
}:

stdenv.mkDerivation rec {
  name = "augeas-1.8.0";

  src = fetchurl {
    url = "http://download.augeas.net/${name}.tar.gz";
    multihash = "QmVSKZutqGJXibnZbp5WSuaXyvmxuoy3uYgVDnEX5RipAq";
    hashOutput = false;
    sha256 = "515ce904138d99ff51d45ba7ed0d809bdee6c42d3bc538c8c820e010392d4cc5";
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
