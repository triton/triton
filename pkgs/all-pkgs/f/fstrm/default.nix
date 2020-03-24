{ stdenv
, fetchurl

, libevent
}:

stdenv.mkDerivation rec {
  name = "fstrm-0.6.0";

  src = fetchurl {
    url = "https://dl.farsightsecurity.com/dist/fstrm/${name}.tar.gz";
    multihash = "QmPBavSFeVnXzTsS5oQuDMRrNRqmbdkKJQrmgZBSZqqPwj";
    hashOutput = false;
    sha256 = "a7049089eb0861ecaa21150a05613caa6dee4e8545b91191eff2269caa923910";
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
