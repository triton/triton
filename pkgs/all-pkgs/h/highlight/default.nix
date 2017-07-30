{ stdenv
, fetchurl
, lib

, getopt
, lua
, boost
}:

stdenv.mkDerivation rec {
  name = "highlight-3.39";

  src = fetchurl {
    url = "http://www.andre-simon.de/zip/${name}.tar.bz2";
    multihash = "QmcFMBs6jpBg6DdTbBwBGd45PSnxF6c9Basju7RGsxczy5";
    hashOutput = false;
    sha256 = "44f2cef6b5c0b89b5c0d76cf39ce4c2944eeff6b9c23ba27d1d153ac93d10f7d";
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
