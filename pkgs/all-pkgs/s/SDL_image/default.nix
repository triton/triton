{ stdenv
, fetchurl
, lib

, libjpeg
, libpng
, libtiff
, libwebp
, SDL
, zlib
}:

let
  version = "2.0.2";
in
stdenv.mkDerivation {
  name = "SDL_image-${version}";

  src = fetchurl {
    url = "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-${version}.tar.gz";
    sha256 = "72df075aef91fc4585098ea7e0b072d416ec7599aa10473719fbe51e9b8f6ce8";
  };

  buildInputs = [
    libjpeg
    libpng
    libtiff
    libwebp
    SDL
    zlib
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
