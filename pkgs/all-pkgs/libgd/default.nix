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
  version = "2.2.2";
in
stdenv.mkDerivation rec {
  name = "libgd-${version}";
  
  src = fetchurl {
    url = "https://github.com/libgd/libgd/releases/download/gd-${version}/${name}.tar.xz";
    sha256 = "489f756ce07f0c034b1a794f4d34fdb4d829256112cb3c36feb40bb56b79218c";
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
