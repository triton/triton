{ stdenv
, cmake
, fetchurl
, ninja

, boost
, libconfuse
, libusb
, python
, swig
}:

stdenv.mkDerivation rec {
  name = "libftdi1-1.3";

  src = fetchurl {
    url = "https://www.intra2net.com/en/developer/libftdi/download/${name}.tar.bz2";
    multihash = "QmUiNXWTKhPBir2RmU7NBFWQqHGZv36vzrg4RcqgjNfQzP";
    sha256 = "9a8c95c94bfbcf36584a0a58a6e2003d9b133213d9202b76aec76302ffaa81f4";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    #boost
    libconfuse
    libusb
    python
    swig
  ];

  postPatch = ''
    sed -i '/add_subdirectory(examples)/d' CMakeLists.txt
  '';

  cmakeFlags = [
    "-DSTATICLIBS=OFF"
    "-DBUILD_TESTS=OFF"
    "-DDOCUMENTATION=OFF"
  ];
  
  postInstall = ''
    rm "$out"/lib*/pkgconfig/libftdipp1.pc
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
