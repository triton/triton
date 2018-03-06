{ stdenv
, cmake
, fetchurl
, lib
, ninja

, glu
, libx11
, libxi
, libxrandr
, libxrender
#, libxxf86vm
, opengl-dummy
, xorg
, xorgproto

, glesSupport ? false
}:

assert glesSupport ->
  opengl-dummy.egl
  && opengl-dummy.glesv1
  && opengl-dummy.glesv2;

let
  inherit (lib)
    boolOn;

  version = "3.0.0";
in
stdenv.mkDerivation rec {
  name = "freeglut-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/freeglut/freeglut/${version}/${name}.tar.gz";
    multihash = "QmTo2cUAxj3gHqYSCRRgbhJebR35yxpKah4DikRmtRCQ6H";
    sha256 = "2a43be8515b01ea82bcfa17d29ae0d40bd128342f0930cd1f375f1ff999f76a2";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    glu
    libx11
    libxi
    libxrandr
    libxrender
    xorg.libXxf86vm
    opengl-dummy
    xorgproto
  ];

  cmakeFlags = [
    "-DFREEGLUT_BUILD_DEMOS=OFF"
    # XXX: Cannot build both libglut and libfreeglut-gles.
    "-DFREEGLUT_GLES=${boolOn glesSupport}"
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
