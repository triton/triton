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

let
  version = "1.4.9";
in
stdenv.mkDerivation rec {
  name = "imlib2-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/enlightenment/imlib2-src/${version}/${name}.tar.bz2";
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
    sed -i 's,@my_libs@,,g' imlib2-config.in
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
