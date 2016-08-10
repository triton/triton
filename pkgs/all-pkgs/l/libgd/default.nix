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
  version = "2.2.3";
in
stdenv.mkDerivation rec {
  name = "libgd-${version}";
  
  src = fetchurl {
    url = "https://github.com/libgd/libgd/releases/download/gd-${version}/${name}.tar.xz";
    sha256 = "746b6cbd6769a22ff3ba6f5756f3512a769bd4cdf4695dff17f4867f25fa7d3c";
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
