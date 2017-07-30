{ stdenv
, fetchFromGitHub
, fetchurl
, lib
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
, safeBitstreamReaderBuild ? true  # Buffer boundary checking in bitreaders
, multithreadBuild ? true  # Multithreading via pthreads/win32 threads
, networkBuild ? true  # Network support
, pixelutilsBuild ? true  # Pixel utils in libavutil
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
, avresampleLibrary ? false  # Libav api compatibility library
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
, chromaprint
#, crystalhd
#, decklinkExtlib ? false
#  , blackmagic-design-desktop-video
, fdk-aac
, flite
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
#, libiec61883, libavc1394
, libgcrypt
, libmodplug
, libmysofa ? null
, libnppSupport ? false
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
, nvenc ? false
, nvidia-cuda-toolkit
, nvidia-drivers
, openal
#, opencl
#, opencore-amr
, opencv
, openh264
, openjpeg
, openssl
, opus
, pulseaudio_lib
, rtmpdump
, rubberband
#, libquvi
, samba_client
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
  inherit (lib)
    boolEn
    optional
    optionals
    optionalString
    versionOlder;

  sources = {
    "3.3" = {
      version = "3.3.3";
      multihash = "QmdtNR6MVR4YppjScd6MJ9Ek2Ga15BJLAR6vXV7RgevKSB";
      sha256 = "d2a9002cdc6b533b59728827186c044ad02ba64841f1b7cd6c21779875453a1e";
    };
    "9.9" = { # Git
      version = "2017.07.28";
      rev = "bf8ab72ae95bb11f2c281d464594c2f6ba70326b";
      sha256 = "b48a4e947018c89e11481a6495e2b703ab194d7e15e8494e5873362f207eb8cc";
    };
  };
  source = sources."${channel}";
in

/*
 *  Licensing dependencies
 */
# GPL
assert
  fdk-aac != null
  #|| avid != null
  #|| avisynth != null
  #|| cdio != null
  || frei0r-plugins != null
  || openssl != null
  || rubberband != null
  || samba_client != null
  #|| utvideo != null
  || vid-stab != null
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
  #decklinkExtlib
  fdk-aac != null
  || libnppSupport
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
  && SDL_2 != null;
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
assert flite != null -> alsa-lib != null;
assert libxcbshmExtlib -> xorg.libxcb != null;
assert libxcbxfixesExtlib -> xorg.libxcb != null;
assert libxcbshapeExtlib -> xorg.libxcb != null;
assert gnutls != null -> openssl == null;
assert openssl != null -> gnutls == null;

let
  # Minimum/maximun/matching version
  reqMin = v: (compareVersions v channel != 1);
  reqMax = v: (compareVersions channel v != 1);
  reqMatch = v: (compareVersions v channel == 0);

  # Usage:
  # f - Configure flag
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
    chromaprint
    flite
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
    libgcrypt
    libmodplug
    libogg
    libraw1394
    libssh
    libtheora
    libva
    libvdpau
    libvorbis
    libvpx
    libwebp
    mesa_noglu
    mfx-dispatcher
    nvidia-cuda-toolkit
    nvidia-drivers
    openal
    openh264
    openjpeg
    opus
    pulseaudio_lib
    rtmpdump
    rubberband
    samba_client
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
    #xorg.libXvMC
    xorg.xproto
    xvidcore
    xz
    zeromq4
    zlib
  ] ++ optionals nonfreeLicensing [
    fdk-aac
    openssl
  ];

  postPatch = ''
    patchShebangs .
  '' + optionalString (frei0r-plugins != null) ''
    sed -i libavfilter/vf_frei0r.c \
      -e 's,/usr,${frei0r-plugins},g'
  '' + optionalString (ladspa-sdk != null) ''
    sed -i libavfilter/af_ladspa.c \
      -e 's,/usr,${ladspa-sdk},g'
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
    "--${boolEn hardcodedTablesBuild}-hardcoded-tables"
    "--${boolEn safeBitstreamReaderBuild}-safe-bitstream-reader"
    "--enable-pthreads"
    "--disable-w32threads"  # windows
    "--disable-os2threads"  # os/2
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
    "--disable-audiotoolbox"  # macos
    "--${boolEn (
      nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-cuda"
    "--${boolEn (
      nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-cuvid"
    "--disable-d3d11va"  # windows
    "--disable-dxva2"  # windows
    "--${boolEn (mfx-dispatcher != null)}-libmfx"
    "--${boolEn libnppSupport}-libnpp"
    #"--${boolEn (mmal != null)}-mmal"
    /**/"--disable-mmal"
    "--${boolEn nvenc}-nvenc"
    "--${boolEn (libva != null)}-vaapi"
    "--disable-vda"  # macos
    "--${boolEn (libvdpau != null)}-vdpau"
    "--disable-videotoolbox"  # macos
    # Undocumented
    # FIXME
    #"--${boolEn (xorg.libXvMC != null)}-xvmc"
    "--disable-xvmc"
    /*
     *  External libraries
     */
    #"--${boolEn (avisynth != null)}-avisynth"
    /**/"--disable-avisynth"
    "--${boolEn (bzip2 != null)}-bzlib"
    # Recursive dependency
    "--${boolEn (chromaprint != null)}-chromaprint"
    # Undocumented (broadcom)
    #"--${boolEn (crystalhd != null)}-crystalhd"
    /**/"--disable-crystalhd"
    "--${boolEn (frei0r-plugins != null)}-frei0r"
    "--${boolEn (libgcrypt != null)}-gcrypt"
    "--${boolEn (gmp != null)}-gmp"
    "--${boolEn (gnutls != null)}-gnutls"
    "--${boolEn (stdenv.cc.libc != null)}-iconv"
    "--${boolEn (jni != null)}-jni"
    "--${boolEn (ladspa-sdk != null)}-ladspa"
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
    "--${boolEn (fdk-aac != null)}-libfdk-aac"
    "--${boolEn (fontconfig != null)}-libfontconfig"
    "--${boolEn (flite != null)}-libflite"
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
    (deprfflag null "3.4" "--disable-libnut")
    #"--${boolEn (opencore-amr != null)}-libopencore-amrnb"
    /**/"--disable-libopencore-amrnb"
    #"--${boolEn (opencore-amr != null)}-libopencore-amrwb"
    /**/"--disable-libopencore-amrwb"
    #"--${boolEn (opencv != null)}-libopencv"
    /**/"--disable-libopencv"
    "--${boolEn (openh264 != null)}-libopenh264"
    "--${boolEn (openjpeg != null)}-libopenjpeg"
    #"--${boolEn (libopenmpt != null)}-libopenmpt"
    /**/"--disable-libopenmpt"
    "--${boolEn (opus != null)}-libopus"
    "--${boolEn (pulseaudio_lib != null)}-libpulse"
    "--${boolEn (rubberband != null)}-librubberband"
    "--${boolEn (rtmpdump != null)}-librtmp"
    (deprfflag null "3.4" "--disable-libschroedinger")
    #"--${boolEn (shine != null)}-libshine"
    /**/"--disable-libshine"
    "--${boolEn (samba_client != null)}-libsmbclient"
    "--${boolEn (snappy != null)}-libsnappy"
    "--${boolEn (soxr != null)}-libsoxr"
    "--${boolEn (speex != null)}-libspeex"
    "--${boolEn (libssh != null)}-libssh"
    #"--${boolEn (tesseract != null)}-libtesseract"
    /**/"--disable-libtesseract"
    "--${boolEn (libtheora != null)}-libtheora"
    #"--${boolEn (twolame != null)}-libtwolame"
    /**/"--disable-libtwolame"
    "--${boolEn (v4l_lib != null)}-libv4l2"
    "--${boolEn (vid-stab != null)}-libvidstab"
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
    "--${boolEn (libzimg != null)}-libzimg"
    "--${boolEn (zeromq4 != null)}-libzmq"
    #"--${boolEn (zvbi != null)}-libzvbi"
    /**/"--disable-libzvbi"
    "--${boolEn (xz != null)}-lzma"
    #"--${boolEn decklinkExtlib}-decklink"
    /**/"--disable-decklink"
    "--disable-mediacodec"  # android
    (fflag "--${boolEn (libmysofa != null)}-libmysofa" "3.4")
    (deprfflag null "3.4" "--disable-netcdf")
    "--${boolEn (openal != null)}-openal"
    #"--${boolEn (opencl != null)}-opencl"
    /**/"--disable-opencl"
    # OpenGL requires libX11 for GLX
    "--${boolEn (mesa_noglu != null && xorg.libX11 != null)}-opengl"
    "--${boolEn (openssl != null)}-openssl"
    "--disable-schannel"  # windows
    "--${boolEn (SDL_2 != null)}-sdl"
    "--${boolEn (SDL_2 != null)}-sdl2"
    "--disable-securetransport"
    #"--${boolEn (xorg.libX11 != null && xorg.libXv != null)}-xlib"
    "--${boolEn (zlib != null)}-zlib"
    /*
     *  Developer flags
     */
    "--${boolEn debugDeveloper}-debug"
    "--${boolEn optimizationsDeveloper}-optimizations"
    "--${boolEn extraWarningsDeveloper}-extra-warnings"
    "--${boolEn strippingDeveloper}-stripping"
  ] ++ optionals (alsa-lib != null && flite != null) [
    # Flite requires alsa but the configure test under specifies
    # dependencies and fails without -lasound.
    "--extra-ldflags=-lasound"
  ];

  # Build qt-faststart executable
  postBuild = optionalString qtFaststartProgram ''
    make tools/qt-faststart
  '';

  postInstall = optionalString qtFaststartProgram ''
    install -D -m 755 -v 'tools/qt-faststart' "$out/bin/qt-faststart"
  '';

  passthru = {
    features = {
      cuda = nvidia-cuda-toolkit != null && nvidia-drivers != null;
    };
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

  meta = with lib; {
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
