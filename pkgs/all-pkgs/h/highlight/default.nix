{ stdenv
, fetchurl
, lib

, getopt
, lua
, boost
}:

stdenv.mkDerivation rec {
  name = "highlight-3.43";

  src = fetchurl {
    url = "http://www.andre-simon.de/zip/${name}.tar.bz2";
    multihash = "QmR6k7Q7RUtEbKpPWtUFyB6zb6q29ZxRSvFHkCCEq17Fg5";
    hashOutput = false;
    sha256 = "db957ebd73048dcb46347f44a1fe8a949fda40b5ecb360bf0df2da0d8d92e902";
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
