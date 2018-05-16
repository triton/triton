{ stdenv
, fetchurl

, libevent
}:

stdenv.mkDerivation rec {
  name = "fstrm-0.4.0";

  src = fetchurl {
    url = "https://dl.farsightsecurity.com/dist/fstrm/${name}.tar.gz";
    multihash = "QmRTZU9G1t6qZG76BLypf2s7jYTVvVqYCpdKjD288BEV2a";
    hashOutput = false;
    sha256 = "b20564cb2ebc7783a8383fbef5bcef5726f94baf48b83843553c9e1030b738ef";
  };

  buildInputs = [
    libevent
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
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
