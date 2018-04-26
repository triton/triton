{ stdenv
, fetchurl
, gettext
, lib

, cairo
, freetype
, giflib
, glib
, libjpeg
, libpng
, libspiro
, libtiff
, libtool
, libuninameslist
, libxml2
, readline
, uthash
, zeromq
, zlib
}:

let
  version = "20170731";
in
stdenv.mkDerivation rec {
  name = "fontforge-${version}";

  src = fetchurl {
    url = "https://github.com/fontforge/fontforge/releases/download/"
      + "${version}/fontforge-dist-${version}.tar.xz";
    sha256 = "840adefbedd1717e6b70b33ad1e7f2b116678fa6a3d52d45316793b9fd808822";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    freetype
    giflib
    glib
    libjpeg
    libpng
    libspiro
    libtiff
    libtool
    libuninameslist
    libxml2
    readline
    zlib
  ];

  # Remove vendoring
  postPatch = ''
    rm -r uthash
    mkdir uthash
    ln -sv '${uthash}'/include uthash/src
  '';

  configureFlags = [
    "--disable-python-extension"
    "--disable-python-scripting"
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

