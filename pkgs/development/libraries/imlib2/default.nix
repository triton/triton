{ stdenv
, fetchurl

, bzip2
, freetype
, giflib
, libid3tag
, libjpeg
, libpng
, libtiff
, xorg
, zlib
}:

stdenv.mkDerivation rec {
  name = "imlib2-1.4.8";

  src = fetchurl {
    url = "mirror://sourceforge/enlightenment/${name}.tar.bz2";
    sha256 = "89ab531ff882c23c8c68e3e941d1bb59dde7a3b2a7853b87ab8c7615da7cb077";
  };

  buildInputs = [
    bzip2
    freetype
    giflib
    libid3tag
    libjpeg
    libpng
    libtiff
    xorg.libICE
    xorg.libX11
    xorg.libXext
    xorg.xextproto
    xorg.xproto
    zlib
  ];

  preConfigure = ''
    substituteInPlace imlib2-config.in \
      --replace "@my_libs@" ""
  '';

  meta = with stdenv.lib; {
    description = "Image manipulation library";
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
