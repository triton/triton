{ stdenv
, fetchurl

, freetype
, fontconfig
, libjpeg
, libpng
, libtiff
, libvpx
, xorg
, zlib
}:

let
  version = "2.2.4";
in
stdenv.mkDerivation rec {
  name = "libgd-${version}";
  
  src = fetchurl {
    url = "https://github.com/libgd/libgd/releases/download/gd-${version}/${name}.tar.xz";
    sha256 = "137f13a7eb93ce72e32ccd7cebdab6874f8cf7ddf31d3a455a68e016ecd9e4e6";
  };

  buildInputs = [
    freetype
    fontconfig
    libjpeg
    libpng
    libtiff
    #libvpx  # This is broken
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
