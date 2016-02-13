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

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "xine-ui-0.99.9";

  src = fetchurl {
    url = "mirror://sourceforge/xine/${name}.tar.xz";
    sha256 = "18liwmkbj75xs9bipw3vr67a7cwmdfcp04v5lph7nsjlkwhq1lcd";
  };

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

  postPatch = ''
    sed -i src/xitk/download.c \
      -e '/curl\/types\.h/d'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--enable-shm"
    "--enable-shm-default"
    (enFlag "xinerama" (xorg.libXinerama != null) null)
    "--enable-aalibtest"
    "--enable-mbs"
    (enFlag "xft" (xorg.libXft != null) null)
    (enFlag "lirc" (lirc != null) null)
    "--enable-vdr-keys"
    "--enable-nvtvsimple"
    "--disable-debug"
    "--with-iconv"
    (wtFlag "x" (xorg != null) null)
    (wtFlag "readline" (readline != null) readline)
    (wtFlag "curl" (curl != null) null)
    "--with-aalib"
    (wtFlag "caca" (libcaca != null) null)
    "--with-fb"
    "--with-tar"
  ];

  LIRC_CFLAGS = "-I${lirc}/include";
  LIRC_LIBS = "-L${lirc}/lib -llirc_client";
  #NIX_LDFLAGS = "-lXext -lgcc_s";

  meta = with stdenv.lib; {
    description = "Xlib-based interface to Xine video player";
    homepage = http://www.xine-project.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
