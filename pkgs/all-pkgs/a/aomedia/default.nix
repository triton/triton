{ stdenv
, cmake
, fetchgit
, lib
, nasm
, ninja
, perl
, python3
}:

let
  version = "2018-04-11";
in
stdenv.mkDerivation rec {
  name = "aomedia-${version}";

  src = fetchgit {
    version = 6;
    url = "https://aomedia.googlesource.com/aom";
    rev = "3cfa8b7a7ecadb56e292056c057238e7218be2ac";
    sha256 = "177b50ee292a3506bba423c93132043b3a93a7472e3c5bdd0baa610d61527b3a";
  };

  nativeBuildInputs = [
    cmake
    nasm
    ninja
    perl
    python3
  ];

  cmakeFlags = [
    "-DENABLE_DOCS=OFF"
    "-DENABLE_NASM=ON"
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
