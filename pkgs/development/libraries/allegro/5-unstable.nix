{ stdenv, fetchurl, texinfo
, alsaLib, cmake, zlib, libpng, libvorbis
, openal, mesa, libjpeg, flac
, xorg }:

stdenv.mkDerivation rec {
  name = "allegro-${version}";
  version = "5.1.11";

  src = fetchurl {
    url = "http://download.gna.org/allegro/allegro-unstable/${version}/${name}.tar.gz";
    sha256 = "0zz07gdyc6xflpvkknwgzsyyyh9qiwd69j42rm9cw1ciwcsic1vs";
  };

  buildInputs = [
    texinfo xorg.libXext xorg.xextproto xorg.libX11 xorg.xproto xorg.libXpm xorg.libXt xorg.libXcursor
    alsaLib cmake zlib libpng libvorbis xorg.libXxf86dga xorg.libXxf86misc
    xorg.xf86dgaproto xorg.xf86miscproto xorg.xf86vidmodeproto xorg.libXxf86vm openal mesa
    xorg.kbproto libjpeg flac xorg.inputproto xorg.libXi xorg.fixesproto xorg.libXfixes
  ];

  patchPhase = ''
    sed -e 's@/XInput2.h@/XI2.h@g' -i CMakeLists.txt "src/"*.c
  '';

  cmakeFlags = [ "-DCMAKE_SKIP_RPATH=ON" ];

  meta = with stdenv.lib; {
    description = "A game programming library";
    homepage = http://liballeg.org/;
    license = licenses.zlib;
    maintainers = [ maintainers.raskin ];
    platforms = platforms.linux;
  };
}
