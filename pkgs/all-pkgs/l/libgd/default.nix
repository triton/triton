{ stdenv
, fetchurl

, freetype
, fontconfig
, libimagequant
, libjpeg
, libpng
, libtiff
, libvpx
, libwebp
, xorg
, zlib
}:

let
  version = "2.2.5";
in
stdenv.mkDerivation rec {
  name = "libgd-${version}";
  
  src = fetchurl {
    url = "https://github.com/libgd/libgd/releases/download/gd-${version}/${name}.tar.xz";
    sha256 = "8c302ccbf467faec732f0741a859eef4ecae22fea2d2ab87467be940842bde51";
  };

  buildInputs = [
    freetype
    fontconfig
    libimagequant
    libjpeg
    libpng
    libtiff
    #libvpx  # This is broken
    libwebp
    xorg.libXpm
    zlib
  ];

  meta = with stdenv.lib; {
    homepage = http://www.libgd.org/;
    description = "An open source code library for the dynamic creation of images by programmers";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
