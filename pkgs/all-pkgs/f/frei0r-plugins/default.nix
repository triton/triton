{ stdenv
, cmake
, fetchurl
, lib
, ninja

, cairo
, opencv
}:

let
  inherit (lib)
    boolOn;
in
stdenv.mkDerivation rec {
  name = "frei0r-plugins-1.6.0";

  src = fetchurl {
    urls = [
      "https://files.dyne.org/frei0r/${name}.tar.gz"
      "https://files.dyne.org/frei0r/releases/${name}.tar.gz"
    ];
    multihash = "QmUXtVFscGUiPk6vwSDu8yqY4tAbkCuN9g6v7qRBRz8fxk";
    hashOutput = false;
    sha256 = "ab2d7254f3a822944252f6c85453eeb8b38fd9368e087034c8d47d68fe6e36fe";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    cairo
    opencv
  ];

  cmakeFlags = [
    "-DWITHOUT_OPENCV=${boolOn (opencv == null)}"
    #"-DWITHOUT_GAVL=${boolOn (cairo == null)}"
    /**/"-DWITHOUT_GAVL=ON"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      sha256Urls = map (n: "${n}.sha") src.urls;
      # Denis Roio (Jaromil)
      pgpKeyFingerprint = "6113 D89C A825 C5CE DD02  C872 73B3 5DA5 4ACB 7D10";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A minimalistic plugin API for video effects";
    homepage = https://www.dyne.org/software/frei0r/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;

  };
}
