{ stdenv
, fetchurl
, lib

, getopt
, lua
, boost
}:

stdenv.mkDerivation rec {
  name = "highlight-3.37";

  src = fetchurl {
    url = "http://www.andre-simon.de/zip/${name}.tar.bz2";
    multihash = "QmP69XxfbqLczjGN79GcsJvmFUPkjkZAFr5VkEUQTL5biP";
    hashOutput = false;
    sha256 = "645a16ff3e4c175b731951ee409377b85c2959212641ae18a9a1e42e2bc985ba";
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

  meta = with lib; {
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
