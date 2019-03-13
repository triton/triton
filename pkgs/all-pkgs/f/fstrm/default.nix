{ stdenv
, fetchurl

, libevent
}:

stdenv.mkDerivation rec {
  name = "fstrm-0.5.0";

  src = fetchurl {
    url = "https://dl.farsightsecurity.com/dist/fstrm/${name}.tar.gz";
    multihash = "QmUmuKHTzsLKHNmUmhnBAGLk7ASBxw8oNugopD8jz6etx8";
    hashOutput = false;
    sha256 = "10ee7792a86face1d2271dc591652ab8c7af6976883887c69fdb11f10da135fc";
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
