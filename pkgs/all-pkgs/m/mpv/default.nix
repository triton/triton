{ stdenv
, fetchzip
, lib
, makeWrapper
, perl
, waf
, which

, alsa-lib
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
, libpthread-stubs
, libtheora
, libva
, libvdpau
, libx11
, libxext
, libxkbcommon
, libxscrnsaver
#, lua
, mujs
, nvidia-cuda-toolkit
, nvidia-drivers
, openal
, opengl-dummy
, pulseaudio_lib
, pythonPackages
, rubberband
, samba_client
, sdl
, speex
, v4l_lib
, wayland
, xorg
, zlib
}:

let
  inherit (lib)
    boolEn;

  version = "0.26.0";
in
stdenv.mkDerivation rec {
  name = "mpv-${version}";

  src = fetchzip {
    version = 3;
    url = "https://github.com/mpv-player/mpv/archive/v${version}.tar.gz";
    sha256 = "0d8eebc876f55ee7f72ed49cf2a1dc72604bffb205ad78eb54514da2051f4ca0";
  };

  nativeBuildInputs = [
    makeWrapper
    perl
    pythonPackages.python
    pythonPackages.docutils
    waf
    which
  ];

  buildInputs = [
    alsa-lib
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
    libpthread-stubs
    libtheora
    libva
    libvdpau
    libx11
    libxext
    libxkbcommon
    libxscrnsaver
    # MPV does not support lua 5.3 yet
    #lua
    #luasockets
    mujs
    nvidia-cuda-toolkit
    nvidia-drivers
    openal
    opengl-dummy
    pulseaudio_lib
    pythonPackages.youtube-dl
    rubberband
    samba_client
    sdl
    speex
    v4l_lib
    wayland
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXv
    xorg.libXxf86vm
    zlib
  ];

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
    "--enable-cplugins"
    "--enable-zsh-comp"
    ###"--enable-asm"
    "--disable-test"
    "--disable-clang-database"
    "--disable-uwp"  # windows
    "--disable-win32-internal-pthreads"
    "--enable-iconv"
    "--disable-termios"
    #"--disable-shm"
    "--${boolEn (samba_client != null)}-libsmbclient"
    #"--${boolEn (lua != null)}-lua"
    /**/"--disable-lua"  # FIXME: need lua 5.2
    "--${boolEn (mujs != null)}-javascript"
    "--${boolEn (libass != null)}-libass"
    "--${boolEn (libass != null)}-libass-osd"
    "--${boolEn (zlib != null)}-zlib"
    "--enable-encoding"
    "--${boolEn (libbluray != null)}-libbluray"
    "--${boolEn (libdvdread != null)}-dvdread"
    "--${boolEn (
      libdvdnav != null
      && libdvdread != null)}-dvdnav"
    # FIXME
    #"--${boolEn (libcdio != null)}-cdda"
    #"--${boolEn ( != null)}-uchardet"
    "--${boolEn (rubberband != null)}-rubberband"
    "--${boolEn (lcms2 != null)}-lcms2"
    #"--${boolEn (vapoursynth != null)}-vapoursynth"
    #"--${boolEn (vapoursynth != null)}-vapoursynth-lazy"
    #"--${boolEn (vapoursynth != null)}-vapoursynth-core"
    "--${boolEn (libarchive != null)}-libarchive"
    "--${boolEn (ffmpeg != null)}-libavdevice"
    "--${boolEn (sdl != null)}-sdl2"
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
    "--disable-audiounit"  # ios
    "--disable-wasapi"  # windows
    "--disable-cocoa"  # macos
    "--${boolEn (libdrm != null)}-drm"
    #"--${boolEn ( != null)}-gbm"
    "--${boolEn (wayland != null && libxkbcommon != null)}-wayland"
    "--${boolEn (
        libx11 != null
        && libxext != null
        && xorg.libXinerama != null
        && xorg.libXrandr != null
        && libxscrnsaver != null)}-x11"
    "--${boolEn (xorg.libXv != null)}-xv"
    "--disable-gl-cocoa"
    # FIXME: add passthru booleans to mesa for feature detection
    # "--${boolEn (mesa.x11-gl-backend != null)}-gl-x11"
    # "--${boolEn (mesa.x11-egl-backend != null)}-egl-x11"
    # "--${boolEn (mesa.drm-egl-backend != null)}-egl-drm"
    # "--${boolEn (mesa.wayland-gl-backend != null)}-gl-wayland"
    "--disable-gl-win32"  # windows
    "--disable-gl-dxinterop"  # windows
    "--disable-egl-angle"  # windows
    "--disable-egl-angle-win32"  # windows
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
    ###"--disable-ios-gl"
    "--disable-plain-gl"
    # FIXME:
    ###"--disable-mali-dbdev"
    "--${boolEn (mesa != null)}-gl"
    "--${boolEn (libva != null)}-vaapi-hwaccel"
    "--disable-videotoolbox-hwaccel-new"  # macos
    "--disable-videotoolbox-hwaccel-old"  # macos
    "--disable-videotoolbox-gl"  # macos
    "--${boolEn (libvdpau != null && ffmpeg != null)}-vdpau-hwaccel"
    "--disable-d3d-hwaccel"  # windows
    "--disable-d3d-hwaccel-new"  # windows
    "--disable-d3d9-hwaccel"  # windows
    "--disable-gl-dxinterop-d3d9"  # windows
    "--${boolEn (
      ffmpeg != null
      && ffmpeg.features.cuda
      && nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-cuda-hwaccel"
    ###"--enable-tv-interface"
    # FIXME
    # "--${boolEn (v4l_lib != null)}-tv-v4l2"
    # "--${boolEn (v4l_lib != null)}-libv4l2"
    # "--${boolEn (v4l_lib != null)}-audio-input"
    #"--${boolEn ( != null)}-dvbin"
    "--disable-apple-remote"
  ];

  postInstall = /* Use a standard font */ ''
    mkdir -pv $out/share/mpv
    ln -sv ${freefont_ttf}/share/fonts/truetype/FreeSans.ttf \
      $out/share/mpv/subfont.ttf
  '';

  preFixup = /* Ensure youtube-dl is available in $PATH for MPV */ ''
    wrapProgram $out/bin/mpv \
      --prefix PATH : "${pythonPackages.youtube-dl}/bin"
  '';

  meta = with lib; {
    description = "A media player that supports many video formats";
    homepage = http://mpv.io;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
