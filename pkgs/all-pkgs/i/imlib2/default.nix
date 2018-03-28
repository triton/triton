{ stdenv
, fetchurl
, lib

, bzip2
, freetype
, giflib
, libid3tag
, libjpeg
, libpng
, libtiff
, libx11
, libxcb
, libxext
, xorgproto
, zlib
}:

let
  version = "1.5.1";
in
stdenv.mkDerivation rec {
  name = "imlib2-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/enlightenment/imlib2-src/${version}/${name}.tar.bz2";
    sha256 = "fa4e57452b8843f4a70f70fd435c746ae2ace813250f8c65f977db5d7914baae";
  };

  buildInputs = [
    bzip2
    freetype
    giflib
    libid3tag
    libjpeg
    libpng
    libtiff
    libx11
    libxcb
    libxext
    xorgproto
    zlib
  ];

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
