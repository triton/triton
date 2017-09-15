{ stdenv
, cmake
, fetchurl
, lib
, ninja

, inputproto
, libx11
, libxrandr
, libxrender
, mesa
, randrproto
, renderproto
, xf86vidmodeproto
, xorg
, xproto
}:

stdenv.mkDerivation rec {
  name = "freeglut-3.0.0";

  src = fetchurl {
    url = "mirror://sourceforge/freeglut/${name}.tar.gz";
    sha256 = "18knkyczzwbmyg8hr4zh8a1i5ga01np2jzd1rwmsh7mh2n2vwhra";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    inputproto
    libx11
    xorg.libXi
    libxrandr
    libxrender
    xorg.libXxf86vm
    mesa
    randrproto
    renderproto
    xf86vidmodeproto
    xproto
  ];

  meta = with lib; {
    description = "Create and manage windows containing OpenGL contexts";
    homepage = http://freeglut.sourceforge.net/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
