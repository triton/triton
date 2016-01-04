{ stdenv, fetchurl, texinfo
, alsaLib, cmake, zlib, libpng, libvorbis
, openal, mesa, xorg }:

stdenv.mkDerivation rec {
  name = "allegro-${version}";
  version="4.4.2";

  src = fetchurl {
    url = "http://download.gna.org/allegro/allegro/${version}/${name}.tar.gz";
    sha256 = "1p0ghkmpc4kwij1z9rzxfv7adnpy4ayi0ifahlns1bdzgmbyf88v";
  };

  buildInputs = [
    texinfo xorg.libXext xorg.xextproto xorg.libX11 xorg.xproto xorg.libXpm xorg.libXt xorg.libXcursor
    alsaLib cmake zlib libpng libvorbis xorg.libXxf86dga xorg.libXxf86misc
    xorg.xf86dgaproto xorg.xf86miscproto xorg.xf86vidmodeproto xorg.libXxf86vm openal mesa
  ];

  cmakeFlags = [ "-DCMAKE_SKIP_RPATH=ON" ];

  meta = with stdenv.lib; {
    description = "A game programming library";
    homepage = http://liballeg.org/;
    license = licenses.free; # giftware
    maintainers = [ maintainers.raskin ];
    platforms = platforms.linux;
  };
}
