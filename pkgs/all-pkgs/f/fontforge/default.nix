{ stdenv
, cmake
, fetchTritonPatch
, fetchurl
, gettext
, lib
, ninja

, cairo
, freetype
, giflib
, glib
, libjpeg
, libpng
, libspiro
, libtiff
, libuninameslist
, libxml2
, python3
, readline
, zeromq
, zlib
}:

let
  version = "20200314";
in
stdenv.mkDerivation rec {
  name = "fontforge-${version}";

  src = fetchurl {
    url = "https://github.com/fontforge/fontforge/releases/download/"
      + "${version}/fontforge-${version}.tar.xz";
    sha256 = "cd190b237353dc3f48ddca7b0b3439da8ec4fcf27911d14cc1ccc76c1a47c861";
  };

  nativeBuildInputs = [
    cmake
    gettext
    ninja
  ];

  buildInputs = [
    freetype
    giflib
    glib
    libjpeg
    libpng
    libspiro
    libtiff
    libuninameslist
    libxml2
    python3
    readline
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "71c7bf99a443b1124fd81d47f6fee20f9ec24c3a";
      file = "f/fontforge/fix.patch";
      sha256 = "3556b3bb487c67456e5e44719faf294e0340a41f8f5a8cbcd5cf9293d78b7505";
    })
  ];

  cmakeFlags = [
    "-DENABLE_GUI=OFF"
    "-DENABLE_DOCS=OFF"
  ];

  meta = with lib; {
    description = "A font editor";
    homepage = http://fontforge.github.io;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

