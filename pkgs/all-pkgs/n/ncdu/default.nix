{ stdenv
, lib
, fetchurl

, ncurses
}:

stdenv.mkDerivation rec {
  name = "ncdu-1.14.2";

  src = fetchurl {
    url = "https://dev.yorhel.nl/download/${name}.tar.gz";
    multihash = "QmfBR9XhUdRjkic8iJGmtdGb8j7BVg2EJJ1CffrCzuc8jh";
    hashOutput = false;
    sha256 = "947a7f5c1d0cd4e338e72b4f5bc5e2873651442cec3cb012e04ad2c37152c6b1";
  };
  
  buildInputs = [
    ncurses
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src) urls outputHash outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "7446 0D32 B808 10EB A9AF  A2E9 6239 4C69 8C27 39FA";
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
