{ stdenv
, cmake
, fetchFromGitHub
, ninja

, mesa
, xorg
}:

stdenv.mkDerivation rec {
  version = "3.1.2";
  name = "glfw-${version}";

  src = fetchFromGitHub {
    owner = "glfw";
    repo = "GLFW";
    rev = "${version}";
    sha256 = "0565ee9782a59262c87169cafed3c43023129d68b8b847cd4bbcd7c791a616c2";
  };

  nativeBuildInputs = [
    cmake
    ninja
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
