{ stdenv
, fetchurl
, shared_mime_info

, curl
, libcaca
, libjpeg
, libpng
, lirc
, ncurses
, readline
, xine-lib
, xorg
}:

stdenv.mkDerivation rec {
  name = "xine-ui-0.99.9";

  src = fetchurl {
    url = "mirror://sourceforge/xine/${name}.tar.xz";
    sha256 = "18liwmkbj75xs9bipw3vr67a7cwmdfcp04v5lph7nsjlkwhq1lcd";
  };

  postPhase = ''
    sed -e '/curl\/types\.h/d' -i src/xitk/download.c
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rapth"
    "--enable-shm"
    "--enable-shm-default"
    "--enable-xinerama"
    "--enable-aalibtest"
    "--enable-mbs"
    "--enable-xft"
    "--enable-lirc"
    "--enable-vdr-keys"
    "--enable-nvtvsimple"
    "--disable-debug"
    "--with-iconv"
    "--with-x"
    "--with-readline=${readline}"
    "--with-curl"
    "--with-aalib"
    "--with-caca"
    "--with-fb"
    "--with-tar"
  ];

  LIRC_CFLAGS="-I${lirc}/include";
  LIRC_LIBS="-L ${lirc}/lib -llirc_client";
  #NIX_LDFLAGS = "-lXext -lgcc_s";

  nativeBuildInputs = [
    shared_mime_info
  ];

  buildInputs = [
    curl
    libcaca
    libjpeg
    libpng
    lirc
    ncurses
    readline
    xine-lib
    xorg.inputproto
    xorg.libX11
    xorg.libXext
    xorg.libXft
    xorg.libXi
    xorg.libXinerama
    xorg.libXt
    xorg.libXtst
    xorg.libXv
    xorg.libXxf86vm
  ];

  meta = {
    homepage = http://www.xine-project.org/;
    description = "Xlib-based interface to Xine, a video player";
  };
}
