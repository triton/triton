{ stdenv
, fetchurl

, libjpeg
, libpng
, libtiff
, libwebp
, SDL
, zlib
}:

let
  version = "2.0.1";
in
stdenv.mkDerivation {
  name = "SDL_image-${version}";

  src = fetchurl {
    url = "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-${version}.tar.gz";
    sha256 = "3a3eafbceea5125c04be585373bfd8b3a18f259bd7eae3efc4e6d8e60e0d7f64";
  };

  buildInputs = [
    libjpeg
    libpng
    libtiff
    libwebp
    SDL
    zlib
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
