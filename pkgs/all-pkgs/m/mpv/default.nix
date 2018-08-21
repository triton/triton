{ stdenv
, fetchFromGitHub
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
, libxinerama
, libxkbcommon
, libxrandr
, libxscrnsaver
, libxv
#, lua
, mujs
, nv-codec-headers
, nvidia-cuda-toolkit
, nvidia-drivers
, openal
, opengl-dummy
, pulseaudio_lib
, python3Packages
, rubberband
, samba_client
, sdl
, speex
, v4l_lib
, vulkan-headers
, wayland
, wayland-protocols
, xorg
, xorgproto
, zlib

, channel
}:

let
  inherit (builtins)
    compareVersions;

  inherit (lib)
    boolEn;

  # Minimum/maximun/matching version
  reqMin = v: (compareVersions v channel != 1);
  reqMax = v: (compareVersions channel v != 1);
  reqMatch = v: (compareVersions v channel == 0);

  # Usage:
  # f - Configure flag
  # v - Version that the configure option was added
  strNew = f: v:
    if v == null || reqMin v  then
      "${f}"
    else
      null;
  strDepr = f: vmin: vmax:
    if (vmin == null || reqMin vmin) && (vmax == null || reqMax vmax) then
      "${f}"
    else
      null;

  sources = {
    "0.29" = rec {
      fetchzipversion = 6;
      version = "0.29.0";
      rev = "v${version}";
      sha256 = "1ab41515f8ab0f713062567885f591299c8d7f67e78477aa04a464edf10d4830";
    };
    "999" = {
      fetchzipversion = 6;
      version = "2018-07-29";
      rev = "5532a3da1ee058443d3162582b601f19b59377c2";
      sha256 = "b4dfcb0912df4d9336b75980dc6e2daccb2027c17b013b67f490c603d8418142";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "mpv-${source.version}";

  src = fetchFromGitHub {
    version = source.fetchzipversion;
    owner = "mpv-player";
    repo = "mpv";
    inherit (source) rev sha256;
  };

  nativeBuildInputs = [
    makeWrapper
    perl
    python3Packages.python
    python3Packages.docutils
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
    libxinerama
    libxkbcommon
    libxrandr
    libxscrnsaver
    libxv
    xorg.libXxf86vm
    # MPV does not support lua 5.3 yet
    #lua
    #luasockets
    mujs
    nv-codec-headers
    nvidia-cuda-toolkit
    nvidia-drivers
    openal
    opengl-dummy
    pulseaudio_lib
    python3Packages.youtube-dl
    rubberband
    samba_client
    sdl
    speex
    v4l_lib
    vulkan-headers
    wayland
    wayland-protocols
    xorgproto
    zlib
  ];

  wafFlags = [
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
    "--disable-android"  # Android
    (strNew "--disable-egl-android" "0.30.0")  # Android
    "--disable-uwp"  # Windows
    "--disable-win32-internal-pthreads"
    "--enable-iconv"
    "--${boolEn (samba_client != null)}-libsmbclient"
    #"--${boolEn (lua != null)}-lua"
    /**/"--disable-lua"  # FIXME: need lua 5.2
    "--${boolEn (mujs != null)}-javascript"
    "--${boolEn (libass != null)}-libass"
    "--${boolEn (libass != null)}-libass-osd"
    "--${boolEn (zlib != null)}-zlib"
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
    "--disable-oss-audio"
    "--disable-rsound"
    #"--${boolEn ( != null)}-sndio"
    "--${boolEn (pulseaudio_lib != null)}-pulse"
    "--${boolEn (jack2_lib != null)}-jack"
    "--${boolEn (openal != null)}-openal"
    "--disable-opensles"  # android
    "--${boolEn (alsa-lib != null)}-alsa"
    "--disable-coreaudio"  # macOS
    "--disable-audiounit"  # iOS
    "--disable-wasapi"  # Windows
    "--disable-cocoa"  # macOS
    "--${boolEn (libdrm != null)}-drm"
    "--enable-drmprime"
    "--${boolEn opengl-dummy.gbm}-gbm"
    "--${boolEn (wayland != null)}-wayland-scanner"
    "--${boolEn (wayland-protocols != null)}-wayland-protocols"
    "--${boolEn (
        wayland != null &&
        wayland-protocols != null &&
        libxkbcommon != null)}-wayland"
    "--${boolEn (
        libx11 != null
        && libxext != null
        && libxinerama != null
        && libxrandr != null
        && libxscrnsaver != null)}-x11"
    "--${boolEn (libxv != null)}-xv"
    "--disable-gl-cocoa"
    "--${boolEn opengl-dummy.glx}-gl-x11"
    "--${boolEn opengl-dummy.egl}-egl-x11"
    "--${boolEn opengl-dummy.egl}-egl-drm"
    "--${boolEn opengl-dummy.gbm}-gl-wayland"
    "--disable-gl-win32"  # Windows
    "--disable-gl-dxinterop"  # Windows
    "--disable-egl-angle"  # Windows
    "--disable-egl-angle-win32"  # Windows
    "--${boolEn (libvdpau != null)}-vdpau"
    # FIXME: add passthru booleans to libvdpau for feature detection
    # "--${boolEn opengl-dummy.glx}-vdpau-gl-x11"  # FIXME
    #"--${boolEn (libva != null)}-vaapi"
    "--${boolEn (libva != null)}-vaapi"
    # FIXME: add passthru booleans to libva for feature detection
    #"--enable-vaapi-x11"
    #"--enable-vaapi-wayland"
    #"--enable-vaapi-drm"
    #"--${boolEn opengl-dummy.glx}-vaapi-glx"
    #"--${boolEn opengl-dummy.egl}-vaapi-x-egl"
    "--${boolEn (libcaca != null)}-caca"
    "--${boolEn (libjpeg != null)}-jpeg"
    "--disable-direct3d"  # Windows
    /**/"--disable-shaderc"
    /**/"--disable-crossc"
    "--disable-d3d11"  # Windows
    "--disable-rpi"  # FIXME: add raspberry pi support
    "--disable-ios-gl"  # iOS
    "--disable-plain-gl"
    "--enable-gl"
    "--disable-mali-fbdev"
    "--${boolEn (opengl-dummy != null)}-gl"
    #"--${boolEn (vulkan-headers != null)}-vulkan"
    /**/"--disable-vulkan"  # FIXME: expects vulkan.pc
    ###"--disable-videotoolbox-hwaccel"  # macOS
    "--disable-videotoolbox-gl"  # macOS
    "--disable-d3d-hwaccel"  # Windows
    "--disable-d3d9-hwaccel"  # Windows
    "--disable-gl-dxinterop-d3d9"  # Windows
    "--${boolEn (
      ffmpeg != null
      && ffmpeg.features.cuda
      && nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-cuda-hwaccel"
    "--enable-tv"
    # FIXME
    # "--${boolEn (v4l_lib != null)}-tv-v4l2"
    # "--${boolEn (v4l_lib != null)}-libv4l2"
    # "--${boolEn (v4l_lib != null)}-audio-input"
    #"--${boolEn ( != null)}-dvbin"
    "--disable-apple-remote"
    "--disable-macos-touchbar"
    "--disable-macos-cocoa-cb"
    #"--disable-swift-flags"
  ];

  postInstall = /* Use a standard font */ ''
    mkdir -pv $out/share/mpv
    ln -sv ${freefont_ttf}/share/fonts/truetype/FreeSans.ttf \
      $out/share/mpv/subfont.ttf
  '';

  preFixup = /* Ensure youtube-dl is available in $PATH for MPV */ ''
    wrapProgram $out/bin/mpv \
      --prefix PATH : "${python3Packages.youtube-dl}/bin"
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
