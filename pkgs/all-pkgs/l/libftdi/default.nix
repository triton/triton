{ stdenv
, cmake
, fetchurl
, ninja

, libconfuse
, libusb
, python
, swig
}:

stdenv.mkDerivation rec {
  name = "libftdi1-1.4";

  src = fetchurl {
    url = "https://www.intra2net.com/en/developer/libftdi/download/${name}.tar.bz2";
    multihash = "QmQietPVmHuxa3nyFJqi8F3yYGnu34d6e6M2HBgwYcJrHR";
    sha256 = "ec36fb49080f834690c24008328a5ef42d3cf584ef4060f3a35aa4681cb31b74";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
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
