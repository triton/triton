{ stdenv
, cmake
, fetchgit
, lib
, ninja
, perl
, yasm
}:

let
  version = "2017-07-03";
in
stdenv.mkDerivation rec {
  name = "aomedia-${version}";

  src = fetchgit {
    version = 3;
    url = "https://aomedia.googlesource.com/aom";
    rev = "7e55571ec483795c90adc1ce664f3da89c51636c";
    sha256 = "1f1ab3900990b32a8cda3577dba962776e11ca43df2a0229fc31fa80b0e5185a";
  };

  nativeBuildInputs = [
    cmake
    ninja
    perl
    yasm
  ];

  cmakeFlags = [
    "-DENABLE_CCACHE=OFF"
    "-DENABLE_DISTCC=OFF"
    "-DENABLE_DOCS=OFF"
    "-DENABLE_NASM=OFF"
    "-DENABLE_IDE_TEST_HOSTING=OFF"
    "-DBUILD_SHARED_LIBS=ON"
  ];

  meta = with lib; {
    description = "AV1 Codec Library";
    homepage = http://aomedia.org/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
