{ stdenv
, cmake
, fetchurl
, ninja
, unzip

, mesa
, xorg
}:

let
  version = "3.2";
in
stdenv.mkDerivation rec {
  name = "glfw-${version}";

  src = fetchurl {
    url = "https://github.com/glfw/glfw/releases/download/${version}/${name}.zip";
    sha256 = "d9983a129732bd400869dd26c9ef2ed253b1da0cfb79585ab7af63a175d0f652";
  };

  nativeBuildInputs = [
    cmake
    ninja
    unzip
  ];

  buildInputs = [
    mesa
    xorg.kbproto
    xorg.libX11
    xorg.libXcursor
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.randrproto
    xorg.renderproto
    xorg.xproto
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
  ];

  meta = with stdenv.lib; { 
    description = "Multi-platform library for creating OpenGL contexts and managing input, including keyboard, mouse, joystick and time";
    homepage = "http://www.glfw.org/";
    license = licenses.zlib;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
