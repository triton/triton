{ stdenv
, cmake
, fetchurl
, lib
, ninja

, bzip2
, openssl
, zlib
}:

stdenv.mkDerivation rec {
  name = "libzip-1.5.1";

  src = fetchurl {
    url = "https://www.nih.at/libzip/${name}.tar.xz";
    multihash = "Qmbqtkmw9eA2Mr8gCffyiNK1a48tbZpkm5jxdS14cgJEqA";
    sha256 = "04ea35b6956c7b3453f1ed3f3fe40e3ddae1f43931089124579e8384e79ed372";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    bzip2
    openssl
    zlib
  ];

  postPatch = ''
    sed -i '/ADD_SUBDIRECTORY(\(regress\|examples\))/d' CMakeLists.txt
  '';

  meta = with lib; {
    homepage = https://www.nih.at/libzip;
    description = "A C library for reading, creating and modifying zip archives";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
