{ stdenv
, cmake
, fetchgit
, lib
, nasm
, ninja
, perl
}:

let
  version = "2017-12-22";
in
stdenv.mkDerivation rec {
  name = "aomedia-${version}";

  src = fetchgit {
    version = 5;
    url = "https://aomedia.googlesource.com/aom";
    rev = "94e3fe3b2f21d4c821336fd85d89bf07f4144d55";
    sha256 = "405cfdc8393d8e34f61bd4401ee38768d98652ac65cfd2a8beb675a85b719078";
  };

  nativeBuildInputs = [
    cmake
    nasm
    ninja
    perl
  ];

  cmakeFlags = [
    "-DENABLE_CCACHE=OFF"
    "-DENABLE_DISTCC=OFF"
    "-DENABLE_DOCS=OFF"
    "-DENABLE_NASM=ON"
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
