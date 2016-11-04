{ stdenv
, fetchFromGitHub
, fetchurl
, perl
, texinfo
, yasm

/*
 *  Licensing options (yes some are listed twice, filters and such are not listed)
 */
, gplLicensing ? true
, version3Licensing ? true
, nonfreeLicensing ? false
/*
 *  Build options
 */
# Optimize for size instead of speed
, smallBuild ? false
# Detect CPU capabilities at runtime (disable to compile natively)
, runtimeCpuDetectBuild ? true
# Full grayscale support
, grayBuild ? true
# Alpha channel support in swscale
, swscaleAlphaBuild ? true
# Hardcode decode tables instead of runtime generation
, hardcodedTablesBuild ? true
, safeBitstreamReaderBuild ? true # Buffer boundary checking in bitreaders
, memalignHackBuild ? false # Emulate memalign
, multithreadBuild ? true # Multithreading via pthreads/win32 threads
, networkBuild ? true # Network support
, pixelutilsBuild ? true # Pixel utils in libavutil
/*
 *  Program options
 */
, ffmpegProgram ? true
, ffplayProgram ? true
, ffprobeProgram ? true
, ffserverProgram ? true
, qtFaststartProgram ? true
/*
 *  Library options
 */
, avcodecLibrary ? true
, avdeviceLibrary ? true
, avfilterLibrary ? true
, avformatLibrary ? true
, avresampleLibrary ? false # Libav api compatibility library
, avutilLibrary ? true
, postprocLibrary ? true
, swresampleLibrary ? true
, swscaleLibrary ? true
/*
 *  Documentation options
 */
, htmlpagesDocumentation ? false
, manpagesDocumentation ? true
, podpagesDocumentation ? false
, txtpagesDocumentation ? false
/*
 *  External libraries options
 */
#, aacplusExtlib ? false, aacplus
, alsa-lib
#, avisynth
, bzip2
, celt
#, chromaprint
#, crystalhd
, dcadec ? null
#, decklinkExtlib ? false
#  , blackmagic-design-desktop-video
, fdk_aac
#, flite
, fontconfig
, freetype
, frei0r-plugins
, fribidi
, game-music-emu
, gmp
, gnutls
, gsm
#, ilbc
, jni ? null
, kvazaar ? null
, jack2_lib
, ladspa-sdk
, lame
, libass
, libbluray
, libbs2b
, libcaca
#, libcdio-paranoia
, libdc1394
, libebur128
#, libiec61883, libavc1394
, libgcrypt
, libmodplug
#, libnut
, libogg
, libraw1394
, libsndio ? null
, libssh
, libtheora
, libva
, libvdpau
, libvorbis
, libvpx
, libwebp
, libxcbshmExtlib ? true
, libxcbxfixesExtlib ? true
, libxcbshapeExtlib ? true
, libzimg ? null
, mesa_noglu
, mfx-dispatcher
, mmal ? null
, netcdf ? null
, nvenc
, nvidia-cuda-toolkit
, openal
#, opencl
#, opencore-amr
, opencv
#, openh264
, openjpeg
, openssl
, opus
, pulseaudio_lib
, rtmpdump
, rubberband
#, libquvi
, samba_client
, schroedinger
, SDL
, SDL_2
#, shine
, snappy
, soxr
, speex
, tesseract
#, twolame
#, utvideo
, v4l_lib
, vid-stab
#, vo-aacenc
, vo-amrwbenc ? null
, wavpack
, x11grabExtlib ? false
, x264
, x265
, xavs
, xorg
, xvidcore
, xz
, zeromq4
, zlib
#, zvbi
/*
 *  Developer options
 */
, debugDeveloper ? false
, optimizationsDeveloper ? true
, extraWarningsDeveloper ? false
, strippingDeveloper ? false

, channel
}:

let
  inherit (builtins)
    compareVersions;
  inherit (stdenv.lib)
    boolEn
    optional
    optionals
    optionalString
    versionOlder;

  source = (import ./sources.nix { })."${channel}";
in

/*
 *  Licensing dependencies
 */
# GPL
assert
  fdk_aac != null
  #|| avid != null
  #|| cdio != null
  || frei0r-plugins != null
  || openssl != null
  || rubberband != null
  || samba_client != null
  #|| utvideo != null
  || vid-stab != null
  || x11grabExtlib
  || x264 != null
  || x265 != null
  || xavs != null
  || xvidcore != null
  #|| zvbi != null
  -> gplLicensing;
# GPL3
assert
  #opencore-amrnb != null
  #|| opencore-amrwb != null
  #||
  samba_client != null
  #|| vo-aacenc != null
  #|| vo-amrwbenc != null
  -> version3Licensing && gplLicensing;
# Non-free
assert
  fdk_aac != null
  #|| libnpp != null
  || nvidia-cuda-toolkit != null
  || openssl != null
  -> nonfreeLicensing && gplLicensing && version3Licensing;
/*
 *  Build dependencies
 */
assert networkBuild -> gnutls != null || openssl != null;
assert pixelutilsBuild -> avutilLibrary;
/*
 *  Program dependencies
 */
assert ffmpegProgram ->
  avcodecLibrary
  && avfilterLibrary
  && avformatLibrary
  && swresampleLibrary;
assert ffplayProgram ->
  avcodecLibrary
  && avformatLibrary
  && swscaleLibrary
  && swresampleLibrary
  && (SDL != null || SDL_2 != null);
assert ffprobeProgram ->
  avcodecLibrary
  && avformatLibrary;
assert ffserverProgram -> avformatLibrary;
/*
 *  Library dependencies
 */
assert avcodecLibrary -> avutilLibrary;
assert avdeviceLibrary ->
  avformatLibrary
  && avcodecLibrary
  && avutilLibrary;
assert avformatLibrary ->
  avcodecLibrary
  && avutilLibrary;
assert avresampleLibrary -> avutilLibrary;
assert postprocLibrary -> avutilLibrary;
assert swresampleLibrary -> soxr != null;
assert swscaleLibrary -> avutilLibrary;
/*
 *  External libraries
 */
assert libxcbshmExtlib -> xorg.libxcb != null;
assert libxcbxfixesExtlib -> xorg.libxcb != null;
assert libxcbshapeExtlib -> xorg.libxcb != null;
assert gnutls != null -> openssl == null;
assert openssl != null -> gnutls == null;
assert x11grabExtlib ->
  xorg.libX11 != null
  && xorg.libXv != null;

let
  # Minimum/maximun/matching version
  reqMin = v: (compareVersions v channel != 1);
  reqMax = v: (compareVersions channel v != 1);
  reqMatch = v: (compareVersions v channel == 0);

  # Usage:
  # f - Configure flags w/o --enable/disable
  # b - Boolean: (some-pkg !=null) or someFlag
  # v - Version that the configure option was added
  fflag = f: v:
    if v == null || reqMin v  then
    "${f}"
    else
      null;
  deprfflag = f: vmin: vmax:
    if (vmin == null || reqMin vmin) && (vmax == null || reqMax vmax) then
    "${f}"
    else
      null;
in

stdenv.mkDerivation rec {
  name = "ffmpeg-${source.version}";

  src =
    if channel == "9.9" then
      fetchFromGitHub {
        version = 2;
        owner = "ffmpeg";
        repo = "ffmpeg";
        inherit (source)
          rev
          sha256;
      }
    else
      fetchurl {
        url = "https://www.ffmpeg.org/releases/${name}.tar.xz";
        hashOutput = false;
        inherit (source)
          multihash
          sha256;
      };

  nativeBuildInputs = [
    perl
    texinfo
    yasm
  ];

  buildInputs = [
    alsa-lib
    bzip2
    celt
    #chromaprint
    fontconfig
    freetype
    frei0r-plugins
    fribidi
    game-music-emu
    gmp
    gsm
    gnutls
    jack2_lib
    ladspa-sdk
    lame
    libass
    libbluray
    libbs2b
    libcaca
    libdc1394
    libebur128
    libgcrypt
    libmodplug
    libogg
    libraw1394
    libssh
    libwebp
    openal
    openjpeg
    opus
    libtheora
    libva
    libvdpau
    libvorbis
    libvpx
    mesa_noglu
    mfx-dispatcher
    pulseaudio_lib
    rtmpdump
    rubberband
    samba_client
    schroedinger
    SDL
    SDL_2
    soxr
    snappy
    speex
    tesseract
    v4l_lib
    vid-stab
    wavpack
    x264
    x265
    xavs
    xorg.libX11
    xorg.libxcb
    xorg.libXext
    xorg.libXfixes
    xorg.libXv
    xorg.xproto
    xvidcore
    xz
    zeromq4
    zlib
  ] ++ optionals nonfreeLicensing [
    nvidia-cuda-toolkit
    fdk_aac
    openssl
  ];

  postPatch = ''
    patchShebangs .
  '';

  configureFlags = [
    /*
     *  Licensing flags
     */
    "--${boolEn gplLicensing}-gpl"
    "--${boolEn version3Licensing}-version3"
    "--${boolEn nonfreeLicensing}-nonfree"
    /*
     *  Build flags
     */
    # On some ARM platforms --enable-thumb
    /**/"--disable-thumb"
    "--enable-shared --disable-static"
    "--enable-pic"
    (if stdenv.cc.isClang then "--cc=clang" else null)
    "--${boolEn smallBuild}-small"
    "--${boolEn runtimeCpuDetectBuild}-runtime-cpudetect"
    "--${boolEn grayBuild}-gray"
    "--${boolEn swscaleAlphaBuild}-swscale-alpha"
    (deprfflag "--disable-incompatible-libav-abi" null "3.1")
    "--${boolEn hardcodedTablesBuild}-hardcoded-tables"
    "--${boolEn safeBitstreamReaderBuild}-safe-bitstream-reader"
    "--${boolEn memalignHackBuild}-memalign-hack"
    "--enable-pthreads"
    "--disable-w32threads" # windows
    "--disable-os2threads" # os/2
    "--${boolEn networkBuild}-network"
    "--${boolEn pixelutilsBuild}-pixelutils"
    /*
     *  Program flags
     */
    "--${boolEn ffmpegProgram}-ffmpeg"
    "--${boolEn ffplayProgram}-ffplay"
    "--${boolEn ffprobeProgram}-ffprobe"
    "--${boolEn ffserverProgram}-ffserver"
    /*
     *  Library flags
     */
    "--${boolEn avcodecLibrary}-avcodec"
    "--${boolEn avdeviceLibrary}-avdevice"
    "--${boolEn avfilterLibrary}-avfilter"
    "--${boolEn avformatLibrary}-avformat"
    "--${boolEn avresampleLibrary}-avresample"
    "--${boolEn avutilLibrary}-avutil"
    "--${boolEn (postprocLibrary && gplLicensing)}-postproc"
    "--${boolEn swresampleLibrary}-swresample"
    "--${boolEn swscaleLibrary}-swscale"
    /*
     *  Documentation flags
     */
    "--${boolEn (
      htmlpagesDocumentation
      || manpagesDocumentation
      || podpagesDocumentation
      || txtpagesDocumentation)}-doc"
    "--${boolEn htmlpagesDocumentation}-htmlpages"
    "--${boolEn manpagesDocumentation}-manpages"
    "--${boolEn podpagesDocumentation}-podpages"
    "--${boolEn txtpagesDocumentation}-txtpages"
    /*
     *  Hardware accelerators
     */
    (fflag "--disable-audiotoolbox" "3.1") # darwin
    (fflag "--${boolEn (nvidia-cuda-toolkit != null)}-cuda" "3.1")
    /**/(fflag "--disable-cuvid" "3.1")
    "--disable-d3d11va" # windows
    "--disable-dxva2" # windows
    "--${boolEn (mfx-dispatcher != null)}-libmfx"
    #(fflag "--${boolEn (npp != null)}-libnpp" "3.1")
    /**/(fflag "--disable-libnpp" "3.1")
    #"--${boolEn (mmal != null)}-mmal"
    /**/"--disable-mmal"
    "--${boolEn nvenc}-nvenc"
    "--${boolEn (libva != null)}-vaapi"
    "--disable-vda" # darwin
    "--${boolEn (libvdpau != null)}-vdpau"
    "--disable-videotoolbox" # darwin
    # Undocumented
    "--enable-xvmc"
    /*
     *  External libraries
     */
    #"--${boolEn (avisynth != null)}-avisynth"
    /**/"--disable-avisynth"
    "--${boolEn (bzip2 != null)}-bzlib"
    # Recursive dependency
    #(fflag "--${boolEn (chromaprint != null)}-chromaprint" "3.0")
    /**/(fflag "--disable-chromaprint" "3.0")
    # Undocumented (broadcom)
    #"--${boolEn (crystalhd != null)}-crystalhd"
    /**/"--disable-crystalhd"
    # fontconfig -> libfontconfig since 3.1
    (deprfflag "--${boolEn (fontconfig != null)}-fontconfig" null "3.0")
    "--${boolEn (frei0r-plugins != null)}-frei0r"
    # Undocumented before 3.0
    (fflag "--${boolEn (libgcrypt != null)}-gcrypt" "3.0")
    (fflag "--${boolEn (gmp != null)}-gmp" "3.0")
    "--${boolEn (gnutls != null)}-gnutls"
    "--${boolEn (stdenv.cc.libc != null)}-iconv"
    (fflag "--${boolEn (jni != null)}-jni" "3.1")
    "--${boolEn (ladspa-sdk != null)}-ladspa"
    (deprfflag "--disable-libaacplus" null "2.8")
    "--${boolEn (libass != null)}-libass"
    "--${boolEn (libbluray != null)}-libbluray"
    "--${boolEn (libbs2b != null)}-libbs2b"
    "--${boolEn (libcaca != null)}-libcaca"
    "--${boolEn (celt != null)}-libcelt"
    #"--${boolEn (libcdio != null)}-libcdio"
    /**/"--disable-libcdio"
    "--${boolEn (
      libdc1394 != null
      && libraw1394 != null)}-libdc1394"
    # Undocumented
    (deprfflag "--${boolEn (dcadec != null)}-libdcadec" null "3.0")
    (fflag "--${boolEn (libebur128 != null)}-libebur128" "3.1")
    (deprfflag "--disable-libfaac" null "3.1")
    (fflag "--${boolEn (fdk_aac != null)}-libfdk-aac" null)
    (fflag "--${boolEn (fontconfig != null)}-libfontconfig" "3.1")
    #"--${boolEn (flite != null)}-libflite"
    /**/"--disable-libflite"
    "--${boolEn (freetype != null)}-libfreetype"
    "--${boolEn (fribidi != null)}-libfribidi"
    "--${boolEn (game-music-emu != null)}-libgme"
    "--${boolEn (gsm != null)}-libgsm"
    #"--${boolEn (
    #  libiec61883 != null
    #  && libavc1394 != null
    #  && libraw1394 != null)}-libiec61883"
    "--disable-libiec61883"
    #"--${boolEn (ilbc != null)}-libilbc"
    "--disable-libilbc"
    "--${boolEn (kvazaar != null)}-libkvazaar"
    "--${boolEn (libmodplug != null)}-libmodplug"
    "--${boolEn (lame != null)}-libmp3lame"
    #"--${boolEn (libnut != null)}-libnut"
    /**/"--disable-libnut"
    #"--${boolEn (opencore-amr != null)}-libopencore-amrnb"
    /**/"--disable-libopencore-amrnb"
    #"--${boolEn (opencore-amr != null)}-libopencore-amrwb"
    /**/"--disable-libopencore-amrwb"
    #"--${boolEn (opencv != null)}-libopencv"
    /**/"--disable-libopencv"
    #"--${boolEn (openh264 != null)}-libopenh264"
    /**/"--disable-libopenh264"
    "--${boolEn (openjpeg != null)}-libopenjpeg"
    #(ffmpeg "--${boolEn (libopenmpt != null)}-libopenmpt" "3.2")
    /**/(fflag "--disable-libopenmpt" "3.2")
    "--${boolEn (opus != null)}-libopus"
    "--${boolEn (pulseaudio_lib != null)}-libpulse"
    (deprfflag "--disable-libquvi" null "2.8")
    (fflag "--${boolEn (rubberband != null)}-librubberband" "3.0")
    "--${boolEn (rtmpdump != null)}-librtmp"
    "--${boolEn (schroedinger != null)}-libschroedinger"
    #"--${boolEn (shine != null)}-libshine"
    /**/"--disable-libshine"
    "--${boolEn (samba_client != null)}-libsmbclient"
    "--${boolEn (snappy != null)}-libsnappy"
    "--${boolEn (soxr != null)}-libsoxr"
    "--${boolEn (speex != null)}-libspeex"
    "--${boolEn (libssh != null)}-libssh"
    #(fflag "--${boolEn (tesseract != null)}-libtesseract" "3.0")
    /**/(fflag "--disable-libtesseract" "3.0")
    "--${boolEn (libtheora != null)}-libtheora"
    #"--${boolEn (twolame != null)}-libtwolame"
    /**/"--disable-libtwolame"
    (deprfflag "--disable-libutvideo" null "3.0")
    "--${boolEn (v4l_lib != null)}-libv4l2"
    "--${boolEn (vid-stab != null)}-libvidstab"
    (deprfflag "--disable-libvo-aacenc" null "2.8")
    "--${boolEn (vo-amrwbenc != null)}-libvo-amrwbenc"
    "--${boolEn (libvorbis != null)}-libvorbis"
    "--${boolEn (libvpx != null)}-libvpx"
    "--${boolEn (wavpack != null)}-libwavpack"
    "--${boolEn (libwebp != null)}-libwebp"
    "--${boolEn (x264 != null)}-libx264"
    "--${boolEn (x265 != null)}-libx265"
    "--${boolEn (xavs != null)}-libxavs"
    #"--${boolEn (xorg.libxcb != null)}-libxcb"
    "--${boolEn libxcbshmExtlib}-libxcb-shm"
    "--${boolEn libxcbxfixesExtlib}-libxcb-xfixes"
    "--${boolEn libxcbshapeExtlib}-libxcb-shape"
    "--${boolEn (xvidcore != null)}-libxvid"
    (fflag "--${boolEn (libzimg != null)}-libzimg" "3.0")
    "--${boolEn (zeromq4 != null)}-libzmq"
    #"--${boolEn (zvbi != null)}-libzvbi"
    /**/"--disable-libzvbi"
    "--${boolEn (xz != null)}-lzma"
    #"--${boolEn decklinkExtlib}-decklink"
    /**/"--disable-decklink"
    (fflag "--disable-mediacodec" "3.1") # android
    (fflag "--${boolEn (netcdf != null)}-netcdf" "3.0")
    "--${boolEn (openal != null)}-openal"
    #"--${boolEn (opencl != null)}-opencl"
    /**/"--disable-opencl"
    # OpenGL requires libX11 for GLX
    "--${boolEn (mesa_noglu != null && xorg.libX11 != null)}-opengl"
    "--${boolEn (openssl != null)}-openssl"
    #(fflag "--${boolEn (schannel != null)}-schannel" "3.0")
    /**/(fflag "--disable-schannel" "3.0")
    (deprfflag "--${boolEn (SDL != null)}-sdl" null "3.1")
    (fflag "--${boolEn (SDL_2 != null)}-sdl2" "3.2")
    "--disable-securetransport"
    "--${boolEn x11grabExtlib}-x11grab"
    #"--${boolEn (xorg.libX11 != null && xorg.libXv != null)}-xlib"
    "--${boolEn (zlib != null)}-zlib"
    /*
     *  Developer flags
     */
    "--${boolEn debugDeveloper}-debug"
    "--${boolEn optimizationsDeveloper}-optimizations"
    "--${boolEn extraWarningsDeveloper}-extra-warnings"
    "--${boolEn strippingDeveloper}-stripping"
  ];

  # Build qt-faststart executable
  postBuild = optionalString qtFaststartProgram ''
    make tools/qt-faststart
  '';

  postInstall = optionalString qtFaststartProgram ''
    install -D -m 755 -v 'tools/qt-faststart' "$out/bin/qt-faststart"
  '';

  passthru = {
    srcVerification = assert channel != "9.9"; fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "FCF9 86EA 15E6 E293 A564  4F10 B432 2F04 D676 58D8";
    };
  };

  meta = with stdenv.lib; {
    description = "Complete solution to record, convert & stream audio/video";
    homepage = http://www.ffmpeg.org/;
    license = (
      if nonfreeLicensing then
        licenses.unfreeRedistributable
      else if version3Licensing then
        licenses.gpl3
      else if gplLicensing then
        licenses.gpl2Plus
      else
        licenses.lgpl21Plus
    );
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
