{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "kelbt-0.16";

  src = fetchurl {
    url = "http://www.colm.net/files/kelbt/${name}.tar.gz";
    multihash = "QmergrtmZGSotED9HSwYEuQAau79QMDejPQ2TrbR4TBb4x";
    hashOutput = false;
    sha256 = "252566b17001b082ad03b8eb5ae0cde9429b661478b605ec018840cba7a2c4b3";
  };

  outputs = [
    "bin"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30";
      };
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
