{ stdenv
, fetchurl

, aalib
, alsaLib
, ffmpeg
, flac
, fontconfig
, freetype
, gdk-pixbuf
, imagemagick
, libbluray
, libcaca
, libcdio
, libdvdcss
, libmng
, libmodplug
, libmpcdec
, libpulseaudio
, libtheora
, libv4l
, libvdpau
, libvorbis
, libvpx
, mesa
, perl
, speex
, vcdimager
, wavpack
, xorg
, zlib
}:

stdenv.mkDerivation rec {
  name = "xine-lib-1.2.6";

  src = fetchurl {
    url = "mirror://sourceforge/xine/${name}.tar.xz";
    sha256 = "01d0nv4zhr4k8id5n4rmw13llrjsv9dhwg1a773c1iqpi1ris15x";
  };

  configureFlags = [
    "--enable-option-checking"
    "--disable-maintainer-mode"
    "--disable-debug"
    "--disable-profiling"
    "--enable-ipv6"
    "--enable-antialiasing"
    "--disable-macosx-universal"
    "--enable-rpath"
    "--disable-iconvtest"
    "--enable-nls"
    "--disable-altivec"
    "--disable-vis"
    "--enable-optimizations"
    "--disable-mmap"
    "--enable-largefile"
    "--disable-coreaudio"
    "--disable-irixal"
    "--disable-oss"
    "--disable-sunaudio"
    #"--enable-sndio"
    "--enable-aalib"
    "--disable-dha-kmod" # requires kernel source
    # TODO: direcfb support
    "--disable-directfb"
    "--enable-dxr3"
    "--enable-fb"
    "--disable-macosx-video"
    "--enable-opengl"
    "--enable-glu"
    "--disable-vidix"
    "--enable-xinerama"
    "--disable-static-xv"
    "--disable-xvmc"
    "--enable-vdpau"
    "--enable-vaapi"
    "--enable-dvb"
    #"--enable-gnomevfs"
    #"--enable-samba"
    "--enable-v4l"
    "--enable-v4l2"
    "--enable-libv4l"
    "--enable-vcd"
    "--enable-vdr"
    "--enable-bluray"
    "--enable-avformat"
    "--enable-a53dec"
    "--enable-asf"
    "--enable-nosefart"
    "--enable-faad"
    "--enable-gdkpixbuf"
    "--enable-libjpeg"
    "--enable-dts"
    "--enable-mad"
    "--enable-modplug"
    "--enable-libmpeg2new"
    "--enable-musepack"
    "--enable-mlib"
    "--enable-mlib-lazyload"
    "--enable-mng"
    "--enable-real-codecs"
    "--disable-w32dll"
    "--enable-vpx"
    #"--enable-mmal" # bcm (broadcomm?) raspberry pi
    "--without-external-libxdg-basedir"
    "--with-freetype"
    "--with-fontconfig"
    "--with-x"
    "--with-alsa"
    "--without-esound"
    "--without-fusionsound"
    #"--with-jack"
    "--with-pulseaudio"
    "--with-caca"
    "--without-dxheaders"
    #"--with-libstk"
    #"--with-sdl"
    "--with-xcb"
    #--with-external-dvdnav  Use external dvdnav library (not recommended)
    "--with-imagemagick"
    "--with-libflac"
    "--with-speex"
    "--with-theora"
    "--with-vorbis"
    "--with-wavpack"
  ];

  NIX_LDFLAGS = "-rpath ${libdvdcss}/lib -L${libdvdcss}/lib -ldvdcss";

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    aalib
    alsaLib
    ffmpeg
    flac
    fontconfig
    freetype
    gdk-pixbuf
    imagemagick
    libbluray
    libcaca
    libcdio
    libdvdcss
    libmng
    libmodplug
    libmpcdec
    libpulseaudio
    libtheora
    libv4l
    libvdpau
    libvorbis
    libvpx
    mesa
    speex
    vcdimager
    wavpack
    xorg.libX11
    xorg.libxcb
    xorg.libXext
    xorg.libXinerama
    xorg.libXv
    zlib
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A multimedia playback engine";
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
