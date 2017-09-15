{ stdenv
, cmake
, fetchurl
, lib
, ninja

, inputproto
, libx11
, libxrandr
, libxrender
, opengl-dummy
, randrproto
, renderproto
, xf86vidmodeproto
, xorg
, xproto
}:

let
  inherit (lib)
    boolOn;
in
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
    opengl-dummy
    randrproto
    renderproto
    xf86vidmodeproto
    xproto
  ];

  cmakeFlags = [
    "-DFREEGLUT_BUILD_DEMOS=OFF"
    # FIXME: is glesv1 or glesv2?
    "-DFREEGLUT_GLES=${boolOn (
      opengl-dummy.egl
      && opengl-dummy.glesv1
      && opengl-dummy.glesv2)}"
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
