{ stdenv
, fetchTritonPatch
, fetchurl

, a52dec
, alsa-lib
, avahi
, bzip2
, dbus
, faad2
, flac
, ffmpeg_2
, freefont_ttf
, fribidi
, gnutls
, jack2_lib
, libass
, libbluray
, libcaca
, libcddb
, libdc1394
, libdvbpsi
, libdvdnav
, libebml
, libgcrypt
, libkate
, libmad
, libmatroska
, libmtp
, liboggz
, libopus
, libraw1394
, librsvg
, libsamplerate
, libtheora
, libtiff
, libtiger
, libupnp
, libva
, libvdpau
, libvorbis
, libxml2
, lua
, libmpeg2
, mesa_noglu
, perl
, pulseaudio_lib
, qt4
#, qt5
, samba
, schroedinger
, SDL
, SDL_image
, speex
, systemd_lib
, taglib
, unzip
, v4l_lib
, xorg
, xz
, zlib

, onlyLibVLC ? false
}:

with {
  inherit (stdenv.lib)
    optional;
};

stdenv.mkDerivation rec {
  name = "vlc-${version}";
  version = "2.2.2";

  src = fetchurl {
    url = "http://get.videolan.org/vlc/${version}/${name}.tar.xz";
    sha256 = "1dazxbmzx2g5570pkg519a7fsj07rdr155kjsw7b9y8npql33lls";
  };

  buildInputs = [
    a52dec
    alsa-lib
    avahi
    bzip2
    dbus
    faad2
    flac
    ffmpeg_2
    freefont_ttf
    fribidi
    gnutls
    jack2_lib
    libass
    libbluray
    libcaca
    libcddb
    libdc1394
    libdvbpsi
    libdvdnav
    libdvdnav.libdvdread
    libebml
    libgcrypt
    libkate
    libmad
    libmatroska
    libmtp
    liboggz
    libopus
    libraw1394
    librsvg
    libsamplerate
    libtheora
    libtiff
    libtiger
    libupnp
    libva
    libvdpau
    libvorbis
    libxml2
    lua
    libmpeg2
    mesa_noglu
    perl
    pulseaudio_lib
    qt4
    #qt5.qtbase
    samba
    schroedinger
    SDL
    SDL_image
    speex
    systemd_lib
    taglib
    unzip
    v4l_lib
    xorg.xcbutilkeysyms
    xorg.libXpm
    xorg.xlibsWrapper
    xorg.libXv
    xorg.libXvMC
    xz
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "2e96cc8e06eaf6ad9643acd1fdddb23aba7759ea";
      file = "vlc/lua_53_compat.patch";
      sha256 = "d1cb88a1037120ea83ef75b2a13039a16825516b776d71597d0e2eae5df2d8fa";
    })
  ];

  postPatch = ''
    sed -e "s@/bin/echo@echo@g" -i configure
  '';

  configureFlags = [
    "--enable-alsa"
    "--with-kde-solid=$out/share/apps/solid/actions"
    "--enable-dc1394"
    "--enable-ncurses"
    "--enable-vdpau"
    "--enable-dvdnav"
    "--enable-samplerate"
  ] ++ optional onlyLibVLC  "--disable-vlc";

  preBuild = ''
    substituteInPlace \
      modules/text_renderer/freetype.c \
      --replace /usr/share/fonts/truetype/freefont/FreeSerifBold.ttf \
      ${freefont_ttf}/share/fonts/truetype/FreeSerifBold.ttf
  '';

  meta = with stdenv.lib; {
    description = "Cross-platform media player and streaming server";
    homepage = http://www.videolan.org/vlc/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
