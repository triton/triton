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

stdenv.mkDerivation rec {
  name = "gd-2.1.1";
  
  src = fetchurl {
    url = "https://github.com/libgd/libgd/releases/download/${name}/lib${name}.tar.xz";
    sha256 = "11djy9flzxczphigqgp7fbbblbq35gqwwhn9xfcckawlapa1xnls";
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
