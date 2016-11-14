{ stdenv
, fetchzip
, makeWrapper
, perl
, pkgconfig
, python
, waf
, which

, alsa-lib
, enca
, ffmpeg
, freefont_ttf
, freetype
, jack2_lib
, lcms2
, libarchive
, libass
, libbluray
, libbs2b
, libcaca
#, libcdio
, libdrm
, libdvdnav
, libdvdread
, libjpeg
, libpng
, libtheora
, libva
, libvdpau
, libxkbcommon
#, lua
#, luaPackages
, mesa
, nvidia-cuda-toolkit
, nvidia-drivers
, openal
, pulseaudio_lib
, pythonPackages
, rubberband
, samba_client
, SDL_2
, speex
, v4l_lib
, wayland
, xorg
}:

let
  inherit (stdenv.lib)
    boolEn;

  version = "0.21.0";
in
stdenv.mkDerivation rec {
  name = "mpv-${version}";

  src = fetchzip {
    version = 2;
    url = "https://github.com/mpv-player/mpv/archive/v${version}.tar.gz";
    sha256 = "5c5210de0d47cb2e34661cfb23b17f3dca8f9ffc86ed73f9d3e7143e32eea1d4";
  };

  nativeBuildInputs = [
    makeWrapper
    perl
    python
    pythonPackages.docutils
    waf
    which
  ];

  buildInputs = [
    alsa-lib
    enca
    ffmpeg
    freefont_ttf
    freetype
    jack2_lib
    lcms2
    libarchive
    libass
    libbluray
    libbs2b
    libcaca
    #libcdio
    libdrm
    libdvdnav
    libdvdread
    libjpeg
    libpng
    libtheora
    libva
    libvdpau
    libxkbcommon
    # MPV does not support lua 5.3 yet
    #lua
    #luaPackages.luasocket
    mesa
    nvidia-cuda-toolkit
    nvidia-drivers
    openal
    pulseaudio_lib
    pythonPackages.youtube-dl
    rubberband
    samba_client
    SDL_2
    speex
    v4l_lib
    wayland
    xorg.libpthreadstubs
    xorg.libX11
    xorg.libXext
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXScrnSaver
    xorg.libXv
    xorg.libXxf86vm
  ];

  postPatch =
    /* https://github.com/mpv-player/mpv/issues/3766
       vdpau configure detection requires a vdpau device to exist.
       This hack replaces the configure test with the test for libdl. */ ''
      sed -i wscript \
        -e 's,libavcodec/vdpau.h,dlfcn.h,' \
        -e "s/.*av_vdpau_bind_context.*/'dlopen\(\"\", 0)',/"
    '';

  configureFlags = [
    ###"--enable-cplayer"
    "--enable-libmpv-shared"
    "--disable-libmpv-static"
    "--disable-libmpv-static"
    "--disable-build-date"  # Purity
    ###"--enable-optimize"
    "--disable-debug-build"
    "--enable-manpage-build"
    "--disable-html-build"
    "--disable-pdf-build"
    "--enable-vf-dlopen-filters"
    "--enable-zsh-comp"
    ###"--enable-asm"
    "--disable-test"
    "--disable-clang-database"
    "--disable-win32-internal-pthreads"
    "--enable-iconv"
    "--disable-termios"
    #"--disable-shm"
    "--${boolEn (samba_client != null)}-libsmbclient"
    #"--${boolEn (lua != null)}-lua"
    "--${boolEn (libass != null)}-libass"
    "--${boolEn (libass != null)}-libass-osd"
    "--enable-encoding"
    "--${boolEn (libbluray != null)}-libbluray"
    "--${boolEn (libdvdread != null)}-dvdread"
    "--${boolEn (libdvdnav != null)}-dvdnav"
    # FIXME
    #"--${boolEn (libcdio != null)}-cdda"
    "--${boolEn (enca != null)}-enca"
    #"--${boolEn ( != null)}-uchardet"
    "--${boolEn (rubberband != null)}-rubberband"
    "--${boolEn (lcms2 != null)}-lcms2"
    #"--${boolEn (vapoursynth != null)}-vapoursynth"
    #"--${boolEn (vapoursynth != null)}-vapoursynth-lazy"
    #"--${boolEn (vapoursynth != null)}-vapoursynth-core"
    "--${boolEn (libarchive != null)}-libarchive"
    "--${boolEn (ffmpeg != null)}-libswresample"
    "--disable-libavresample"
    "--${boolEn (ffmpeg != null)}-libavdevice"
    "--${boolEn (SDL_2 != null)}-sdl2"
    "--disable-sdl1"
    "--disable-oss-audio"
    "--disable-rsound"
    #"--${boolEn ( != null)}-sndio"
    "--${boolEn (pulseaudio_lib != null)}-pulse"
    "--${boolEn (jack2_lib != null)}-jack"
    "--${boolEn (openal != null)}-openal"
    "--disable-opensles"  # android
    "--${boolEn (alsa-lib != null)}-alsa"
    "--disable-coreaudio"  # macos
    ###"--disable-audiounit"  # ios
    "--disable-wasapi"  # windows
    "--disable-cocoa"  # macos
    "--${boolEn (libdrm != null)}-drm"
    #"--${boolEn ( != null)}-gbm"
    "--${boolEn (wayland != null && libxkbcommon != null)}-wayland"
    "--${boolEn (xorg.libX11 != null)}-x11"
    "--${boolEn (xorg.libXScrnSaver != null)}-xss"
    "--${boolEn (xorg.libXext != null)}-xext"
    "--${boolEn (xorg.libXv != null)}-xv"
    "--${boolEn (xorg.libXinerama != null)}-xinerama"
    "--${boolEn (xorg.libXrandr != null)}-xrandr"
    "--disable-gl-cocoa"
    # FIXME: add passthru booleans to mesa for feature detection
    # "--${boolEn (mesa.x11-gl-backend != null)}-gl-x11"
    # "--${boolEn (mesa.x11-egl-backend != null)}-egl-x11"
    # "--${boolEn (mesa.drm-egl-backend != null)}-egl-drm"
    # "--${boolEn (mesa.wayland-gl-backend != null)}-gl-wayland"
    "--disable-gl-win32"  # windows
    "--disable-gl-dxinterop"  # windows
    "--disable-egl-angle"  # windows
    "--${boolEn (libvdpau != null)}-vdpau"
    # FIXME: add passthru booleans to libvdpau for feature detection
    #"--${boolEn ( != null)}-vdpau-gl-x11"
    "--${boolEn (libva != null)}-vaapi"
    # FIXME: add passthru booleans to libva for feature detection
    # "--${boolEn ( != null)}-vaapi-x11"
    # "--${boolEn ( != null)}-vaapi-wayland"
    # "--${boolEn ( != null)}-vaapi-drm"
    # "--${boolEn ( != null)}-vaapi-glx"
    # "--${boolEn ( != null)}-vaapi-x-egl"
    "--${boolEn (libcaca != null)}-caca"
    "--${boolEn (libjpeg != null)}-jpeg"
    "--disable-direct3d"  # windows
    "--disable-android"  # android
    # FIXME: add raspberry pi support
    "--disable-rpi"
    "--${boolEn (mesa != null)}-standard-gl"
    "--disable-android-gl"
    ###"--disable-ios-gl"
    "--${boolEn (mesa != null)}-any-gl"
    "--disable-plain-gl"
    # FIXME:
    ###"--disable-mali-dbdev"
    "--${boolEn (mesa != null)}-gl"
    "--${boolEn (libva != null)}-vaapi-hwaccel"
    "--disable-videotoolbox-hwaccel"
    "--disable-videotoolbox-gl"
    "--${boolEn (libvdpau != null && ffmpeg != null)}-vdpau-hwaccel"
    "--disable-d3d-hwaccel"
    "--${boolEn (
      ffmpeg != null
      && ffmpeg.features.cuda
      && nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-cuda-hwaccel"
    ###"--enable-tv-interface"
    "--${boolEn (v4l_lib != null)}-tv-v4l2"
    "--${boolEn (v4l_lib != null)}-libv4l2"
    "--${boolEn (v4l_lib != null)}-audio-input"
    #"--${boolEn ( != null)}-dvbin"
    "--disable-apple-remote"
  ];

  postInstall = /* Use a standard font */ ''
    mkdir -pv $out/share/mpv
    ln -sv ${freefont_ttf}/share/fonts/truetype/FreeSans.ttf \
      $out/share/mpv/subfont.ttf
  '';

  preFixup =
    /* Ensure youtube-dl is available in $PATH for MPV */ ''
      wrapProgram $out/bin/mpv \
        --prefix PATH : "${pythonPackages.youtube-dl}/bin"
    '';

  meta = with stdenv.lib; {
    description = "A media player that supports many video formats";
    homepage = http://mpv.io;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
