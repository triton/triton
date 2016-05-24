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
  name = "imlib2-1.4.9";

  src = fetchurl {
    url = "mirror://sourceforge/enlightenment/${name}.tar.bz2";
    multihash = "QmW4JVeh256xcdS6MGvRjDQCYHRjCSEKFNBxj5n6GAbJCc";
    sha256 = "7d2864972801823ce44ca8d5584a67a88f0e54e2bf47fa8cf4a514317b4f0021";
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
