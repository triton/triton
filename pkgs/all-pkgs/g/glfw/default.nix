{ stdenv
, cmake
, fetchurl
, lib
, ninja
, unzip

, libx11
, libxcursor
, libxinerama
, libxrandr
, libxrender
, opengl-dummy
, xorgproto
}:

let
  version = "3.2.1";
in
stdenv.mkDerivation rec {
  name = "glfw-${version}";

  src = fetchurl {
    url = "https://github.com/glfw/glfw/releases/download/"
      + "${version}/${name}.zip";
    sha256 = "b7d55e13e07095119e7d5f6792586dd0849c9fcdd867d49a4a5ac31f982f7326";
  };

  nativeBuildInputs = [
    cmake
    ninja
    unzip
  ];

  buildInputs = [
    libx11
    libxcursor
    libxinerama
    libxrandr
    libxrender
    opengl-dummy
    xorgproto
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
  ];

  meta = with lib; {
    description = "Library for creating OpenGL contexts and managing input";
    homepage = "http://www.glfw.org/";
    license = licenses.zlib;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
