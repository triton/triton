{ stdenv
, fetchurl
, lib

, glu
, libx11
, opengl-dummy
, xorgproto
}:

let
  version = "2.1.0";
in
stdenv.mkDerivation rec {
  name = "glew-${version}";

  src = fetchurl {
    url = "https://github.com/nigels-com/glew/releases/download/"
      + "${name}/${name}.tgz";
    sha256 = "04de91e7e6763039bc11940095cd9c7f880baba82196a7765f727ac05a993c95";
  };

  buildInputs = [
    glu
    libx11
    opengl-dummy
    xorgproto
  ];

  postPatch = ''
    sed -i Makefile \
      -e "s,/usr,$out,g"
  '';

  meta = with lib; {
    description = "The OpenGL Extension Wrangler Library";
    homepage = https://github.com/nigels-com/glew;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
