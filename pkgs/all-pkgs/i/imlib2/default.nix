{ stdenv
, fetchurl
, lib

, bzip2
, freetype
, giflib
, libice
, libid3tag
, libjpeg
, libpng
, libtiff
, libx11
, libxext
, xorgproto
, zlib
}:

let
  version = "1.4.10";
in
stdenv.mkDerivation rec {
  name = "imlib2-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/enlightenment/imlib2-src/${version}/${name}.tar.bz2";
    sha256 = "3f698cd285cbbfc251c1d6405f249b99fafffafa5e0a5ecf0ca7ae49bbc0a272";
  };

  buildInputs = [
    bzip2
    freetype
    giflib
    libice
    libid3tag
    libjpeg
    libpng
    libtiff
    libx11
    libxext
    xorgproto
    zlib
  ];

  preConfigure = ''
    sed -i 's,@my_libs@,,g' imlib2-config.in
  '';

  meta = with lib; {
    description = "Image manipulation library";
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
