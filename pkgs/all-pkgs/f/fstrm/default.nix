{ stdenv
, fetchurl

, libevent
}:

stdenv.mkDerivation rec {
  name = "fstrm-0.3.2";

  src = fetchurl {
    url = "https://dl.farsightsecurity.com/dist/fstrm/${name}.tar.gz";
    multihash = "QmNy73Qze5KLFLKexm5m8bRWT5h8S7A8ySiYjMwPCfijQF";
    hashOutput = false;
    sha256 = "2d509999ac904e48c038f88820f47859da85ceb86c06552e4052897082423ec5";
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
