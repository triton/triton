{ stdenv
, lib
, fetchurl

, ncurses
}:

stdenv.mkDerivation rec {
  name = "ncdu-1.13";

  src = fetchurl {
    url = "https://dev.yorhel.nl/download/${name}.tar.gz";
    multihash = "QmX9trpxBMrxLD1eCBm9gAMQ65tAwnSkHwzbByoTq229wG";
    hashOutput = false;
    sha256 = "f4d9285c38292c2de05e444d0ba271cbfe1a705eee37c2b23ea7c448ab37255a";
  };
  
  buildInputs = [
    ncurses
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "7446 0D32 B808 10EB A9AF  A2E9 6239 4C69 8C27 39FA";
      inherit (src) urls outputHash outputHashAlgo;
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
