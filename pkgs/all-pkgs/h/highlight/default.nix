{ stdenv
, fetchurl
, lib

, getopt
, lua
, boost
}:

stdenv.mkDerivation rec {
  name = "highlight-3.40";

  src = fetchurl {
    url = "http://www.andre-simon.de/zip/${name}.tar.bz2";
    multihash = "QmXdTfqwvaEZ4JDVbjwKx8pzzJ5thfyBz6CPDBZWJrTQd7";
    hashOutput = false;
    sha256 = "3e55fadd3f2a85f25ea995fd0e57e94e2a59fe2e3ccefe6bd896b50acadc38e3";
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
