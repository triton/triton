{ stdenv
, fetchurl
, lib

, libjpeg
, libpng
, libtiff
, libwebp
, sdl
, zlib
}:

let
  version = "2.0.3";
in
stdenv.mkDerivation rec {
  name = "sdl-image-${version}";

  src = fetchurl {
    url = "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-${version}.tar.gz";
    hashOutput = false;
    sha256 = "3510c25da735ffcd8ce3b65073150ff4f7f9493b866e85b83738083b556d2368";
  };

  buildInputs = [
    libjpeg
    libpng
    libtiff
    libwebp
    sdl
    zlib
  ];

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1528 635D 8053 A57F 77D1  E086 30A5 9377 A776 3BE6";
      failEarly = true;
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
