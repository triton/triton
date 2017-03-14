{ stdenv
, fetchurl

, getopt
, lua
, boost
}:

stdenv.mkDerivation rec {
  name = "highlight-3.35";

  src = fetchurl {
    url = "http://www.andre-simon.de/zip/${name}.tar.bz2";
    multihash = "QmUVcLcCg4Dsjf2qPJ2NTcW7pYA7LSEjo4Waz6MW4WNjtY";
    hashOutput = false;
    sha256 = "8a14b49f5e0c07daa9f40b4ce674baa00bb20061079473a5d386656f6d236d05";
  };

  buildInputs = [
    getopt
    lua
    boost
  ];

  preConfigure = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "conf_dir=$out/etc/highlight/"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # Andre Simon
        "B8C5 5574 187F 4918 0EDC 7637 50FE 0279 D805 A7C7"
      ];
    };
  };

  meta = with stdenv.lib; {
    description = "Source code highlighting tool";
    homepage = http://www.andre-simon.de/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
