{ stdenv
, cmake
, fetchurl
, lib
, ninja

, glu
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

, glesSupport ? false
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
    glu
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
    # XXX: Cannot build both libglut and libfreeglut-gles.
    "-DFREEGLUT_GLES=${boolOn (
      glesSupport
      && opengl-dummy.egl
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
