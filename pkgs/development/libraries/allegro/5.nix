{ stdenv, fetchurl, texinfo
, alsaLib, cmake, zlib, libpng, libvorbis
, openal, mesa, libjpeg, flac, xorg }:

stdenv.mkDerivation rec {
  name = "allegro-${version}";
  version = "5.0.11";

  src = fetchurl {
    url = "http://download.gna.org/allegro/allegro/${version}/${name}.tar.gz";
    sha256 = "0cd51qrh97jrr0xdmnivqgwljpmizg8pixsgvc4blqqlaz4i9zj9";
  };

  buildInputs = [
    texinfo xorg.libXext xorg.xextproto xorg.libX11 xorg.xproto xorg.libXpm xorg.libXt xorg.libXcursor
    alsaLib cmake zlib libpng libvorbis xorg.libXxf86dga xorg.libXxf86misc
    xorg.xf86dgaproto xorg.xf86miscproto xorg.xf86vidmodeproto xorg.libXxf86vm openal mesa
    xorg.kbproto libjpeg flac
  ];

  cmakeFlags = [ "-DCMAKE_SKIP_RPATH=ON" ];

  meta = with stdenv.lib; {
    description = "A game programming library";
    homepage = http://liballeg.org/;
    license = licenses.zlib;
    maintainers = [ maintainers.raskin ];
    platforms = platforms.linux;
  };
}
