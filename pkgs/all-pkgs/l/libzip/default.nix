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
  name = "libzip-1.5.0";

  src = fetchurl {
    url = "https://www.nih.at/libzip/${name}.tar.xz";
    multihash = "QmUG2XDT5gwk7C7VnXkc8TLxfZPfBQ9BBTiuktFjhzmu1K";
    sha256 = "5ddb9b41d31b2f99ad4d512003c610ae2db70e222833aba6f9332d5b48a153d9";
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
