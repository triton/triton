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
, avresampleLibrary ? true
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
, cudaExtLib ? false
  , nvidia-cuda-toolkit
, dcadec ? null
#, decklinkExtlib ? false
#  , blackmagic-design-desktop-video
, faacExtlib ? false
  , faac
, fdkaacExtlib ? false
  , fdk_aac ? null
#, flite
, fontconfig
, freetype
, frei0r
, fribidi
, game-music-emu
, gmp
, gnutls
, gsm
#, ilbc
, jni ? null
, kvazaar ? null
, jack2_lib
, ladspaH
, lame
, libass
, libbluray
, libbs2b
, libcaca
#, libcdio-paranoia
, libdc1394, libraw1394
#, libiec61883, libavc1394
, libgcrypt
, libmodplug
#, libnut
, libogg
, opus
, libsndio ? null
, libssh
, libtheora
, libva
, libvdpau
, libvorbis
, libvpx
, libwebp
, xorg
, libxcbshmExtlib ? true
, libxcbxfixesExtlib ? true
, libxcbshapeExtlib ? true
, libzimg ? null
, mfx-dispatcher
, mmal ? null
, netcdf ? null
, nvencExtLib ? false
  , nvidia-video-codec-sdk
, openal
#, opencl
#, opencore-amr
, opencv
, mesa_noglu
#, openh264
, openjpeg_1-5
, opensslExtlib ? false, openssl
, pulseaudio_lib
, rtmpdump
, rubberband
#, libquvi
, samba_client
, schroedinger
, SDL
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
  fdkaacExtlib
  #|| avid != null
  #|| cdio != null
  || frei0r != null
  || opensslExtlib
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
assert version3Licensing -> gplLicensing;
assert
  #opencore-amrnb != null
  #|| opencore-amrwb != null
  #||
  samba_client != null
  #|| vo-aacenc != null
  #|| vo-amrwbenc != null
  -> version3Licensing;
# Non-free
assert nonfreeLicensing ->
  gplLicensing
  && version3Licensing;
assert
  opensslExtlib
  || fdkaacExtlib
  || faacExtlib
  #|| aacplusExtlib
  || nvencExtLib
  #|| blackmagic
  -> nonfreeLicensing;
/*
 *  Build dependencies
 */
assert networkBuild ->
  gnutls != null
  || opensslExtlib;
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
  && SDL != null;
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
#assert decklinkExtlib ->
#  blackmagic-design-desktop-video != null
#  && multithreadBuild;
assert faacExtlib -> faac != null;
assert fdkaacExtlib -> fdk_aac != null;
assert gnutls != null -> !opensslExtlib;
assert libxcbshmExtlib -> xorg.libxcb != null;
assert libxcbxfixesExtlib -> xorg.libxcb != null;
assert libxcbshapeExtlib -> xorg.libxcb != null;
assert nvencExtLib -> nvidia-video-codec-sdk != null;
assert opensslExtlib ->
  gnutls == null
  && openssl != null;
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
  fflag = f: b: v:
    if v == null || reqMin v  then
    "--${boolEn b}-${f}"
    else
      null;
  deprfflag = f: b: vmin: vmax:
    if (vmin == null || reqMin vmin) && (vmax == null || reqMax vmax) then
    "--${boolEn b}-${f}"
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
    frei0r
    fribidi
    game-music-emu
    gmp
    gsm
    gnutls
    jack2_lib
    ladspaH
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
    libwebp
    openal
    openjpeg_1-5
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
    faac
    fdk_aac
    openssl
    nvidia-video-codec-sdk
  ];

  postPatch = ''
    patchShebangs .
  '' + optionalString (versionOlder "2.8" channel) ''
    sed -i libavcodec/libvpxenc.c \
      -e '/VP8E_UPD_ENTROPY/d' \
      -e '/VP8E_USE_REFERENCE/d' \
      -e '/VP8E_UPD_REFERENCE/d' \
      -e '/VP8D_USE_REFERENCE/d'
  '';

  configureFlags = [
    /*
     *  Licensing flags
     */
    (fflag "gpl" gplLicensing null)
    (fflag "version3" version3Licensing null)
    (fflag "nonfree" nonfreeLicensing null)
    /*
     *  Build flags
     */
    # On some ARM platforms --enable-thumb
    /**/"--disable-thumb"
    "--enable-shared --disable-static"
    (fflag "pic" true "-")
    (if stdenv.cc.isClang then "--cc=clang" else null)
    (fflag "small" smallBuild null)
    (fflag "runtime-cpudetect" runtimeCpuDetectBuild null)
    (fflag "gray" grayBuild null)
    (fflag "swscale-alpha" swscaleAlphaBuild null)
    "--disable-incompatible-libav-abi"
    (fflag "hardcoded-tables" hardcodedTablesBuild null)
    (fflag "safe-bitstream-reader" safeBitstreamReaderBuild null)
    (fflag "memalign-hack" memalignHackBuild null)
    "--enable-pthreads"
    "--disable-w32threads" # windows
    "--disable-os2threads" # os/2
    (fflag "network" networkBuild null)
    (fflag "pixelutils" pixelutilsBuild null)
    /*
     *  Program flags
     */
    (fflag "ffmpeg" ffmpegProgram null)
    (fflag "ffplay" ffplayProgram null)
    (fflag "ffprobe" ffprobeProgram null)
    (fflag "ffserver" ffserverProgram null)
    /*
     *  Library flags
     */
    (fflag "avcodec" avcodecLibrary null)
    (fflag "avdevice" avdeviceLibrary null)
    (fflag "avfilter" avfilterLibrary null)
    (fflag "avformat" avformatLibrary null)
    (fflag "avresample" avresampleLibrary null)
    (fflag "avutil" avutilLibrary null)
    (fflag "postproc" (
      postprocLibrary
      && gplLicensing) null)
    (fflag "swresample" swresampleLibrary null)
    (fflag "swscale" swscaleLibrary null)
    /*
     *  Documentation flags
     */
    (fflag "doc" (
      htmlpagesDocumentation
      || manpagesDocumentation
      || podpagesDocumentation
      || txtpagesDocumentation) null)
    (fflag "htmlpages" htmlpagesDocumentation null)
    (fflag "manpages" manpagesDocumentation null)
    (fflag "podpages" podpagesDocumentation null)
    (fflag "txtpages" txtpagesDocumentation null)
    /*
     *  Hardware accelerators
     */
    (fflag "audiotoolbox" false "3.1") # darwin
    (fflag "cuda" cudaExtLib "3.1")
    /**/(fflag "cuvid" false "3.1")
    "--disable-d3d11va" # windows
    "--disable-dxva2" # windows
    (fflag "libmfx" (mfx-dispatcher != null) "2.6")
    #(fflag "libnpp" (npp != null) "3.1")
    /**/(fflag "libnpp" false "3.1")
    #(fflag "mmal" (mmal != null) "2.7")
    /**/"--disable-mmal"
    (fflag "nvenc" nvencExtLib "2.6")
    (fflag "vaapi" (libva != null) null)
    "--disable-vda" # darwin
    (fflag "vdpau" (libvdpau != null) null)
    "--disable-videotoolbox" # darwin
    # Undocumented
    "--enable-xvmc"
    /*
     *  External libraries
     */
    #(fflag "avisynth" (avisynth != null) null)
    /**/"--disable-avisynth"
    (fflag "bzlib" (bzip2 != null) null)
    # Recursive dependency
    #(fflag "chromaprint" (chromaprint != null) "3.0")
    /**/(fflag "chromaprint" false "3.0")
    # Undocumented (broadcom)
    #(fflag "crystalhd" (crystalhd != null) null)
    /**/"--disable-crystalhd"
    # fontconfig -> libfontconfig since 3.1
    (deprfflag "fontconfig" (fontconfig != null) "0.0" "3.0")
    (fflag "frei0r" (frei0r != null) null)
    # Undocumented before 3.0
    (fflag "gcrypt" (libgcrypt != null) "3.0")
    (fflag "gmp" (gmp != null) "3.0")
    (fflag "gnutls" (
      gnutls != null
      && !opensslExtlib) null)
    (fflag "iconv" (stdenv.cc.libc != null) null)
    (fflag "jni" (jni != null) "3.1")
    (fflag "ladspa" (ladspaH != null) "2.1")
    (deprfflag "libaacplus" false "0.7" "2.8")
    (fflag "libass" (libass != null) null)
    (fflag "libbluray" (libbluray != null) null)
    (fflag "libbs2b" (libbs2b != null) "2.3")
    (fflag "libcaca" (libcaca != null) null)
    (fflag "libcelt" (celt != null) null)
    #(fflag "libcdio" (libcdio != null) null)
    /**/"--disable-libcdio"
    (fflag "libdc1394" (
      libdc1394 != null
      && libraw1394 != null) null)
    # Undocumented
    (deprfflag "libdcadec" (dcadec != null) "2.7" "3.0")
    #(fflag "libebur128" (libebur128 != null) "3.1")
    /**/(fflag "libebur128" false "3.1")
    (deprfflag "libfaac" faacExtlib null "3.1")
    (fflag "libfdk-aac" fdkaacExtlib null)
    (fflag "libfontconfig" (fontconfig != null) "3.1")
    #(fflag "libflite" (flite != null) null)
    /**/"--disable-libflite"
    (fflag "libfreetype" (freetype != null) null)
    (fflag "libfribidi" (fribidi != null) "2.3")
    (fflag "libgme" (game-music-emu != null) "2.2")
    #(fflag "libgsm" (gsm != null) null)
    /**/"--disable-libgsm"
    #(fflag "libiec61883" (
    #  libiec61883 != null
    #  && libavc1394 != null
    #  && libraw1394 != null) null)
    "--disable-libiec61883"
    #(fflag "libilbc" (ilbc != null) null)
    "--disable-libilbc"
    (fflag "libkvazaar" (kvazaar != null) "2.8")
    (fflag "libmodplug" (libmodplug != null) null)
    (fflag "libmp3lame" (lame != null) null)
    #(fflag "libnut" (libnut != null) null)
    /**/"--disable-libnut"
    #(fflag "libopencore-amrnb" (opencore-amr != null) null)
    /**/"--disable-libopencore-amrnb"
    #(fflag "libopencore-amrwb" (opencore-amr != null) null)
    /**/"--disable-libopencore-amrwb"
    #(fflag "libopencv" (opencv != null) null)
    /**/"--disable-libopencv"
    #(fflag "libopenh264" (openh264 != null) "2.6")
    /**/"--disable-libopenh264"
    (fflag "libopenjpeg" (openjpeg_1-5 != null) null)
    (fflag "libopus" (opus != null) null)
    (fflag "libpulse" (pulseaudio_lib != null) null)
    (deprfflag "libquvi" false "2.0" "2.8")
    (fflag "librubberband" (rubberband != null) "3.0")
    (fflag "librtmp" (rtmpdump != null) null)
    (fflag "libschroedinger" (schroedinger != null) null)
    #(fflag "libshine" (shine != null) "2.0")
    /**/"--disable-libshine"
    (fflag "libsmbclient" (samba_client != null) "2.3")
    (fflag "libsnappy" (snappy != null) "2.8")
    (fflag "libsoxr" (soxr != null) null)
    (fflag "libspeex" (speex != null) null)
    (fflag "libssh" (libssh != null) "2.1")
    #(fflag "libtesseract" (tesseract != null) "3.0")
    /**/(fflag "libtesseract" false "3.0")
    (fflag "libtheora" (libtheora != null) null)
    #(fflag "libtwolame" (twolame != null) null)
    /**/"--disable-libtwolame"
    (deprfflag "libutvideo" false "0.0" "3.0")
    (fflag "libv4l2" (v4l_lib != null) null)
    (fflag "libvidstab" (vid-stab != null) "2.2")
    (deprfflag "libvo-aacenc" false "0.6" "2.8")
    (fflag "libvo-amrwbenc" (vo-amrwbenc != null) null)
    (fflag "libvorbis" (libvorbis != null) null)
    (fflag "libvpx" (libvpx != null) null)
    (fflag "libwavpack" (wavpack != null) "2.0")
    (fflag "libwebp" (libwebp != null) "2.2")
    (fflag "libx264" (x264 != null) null)
    (fflag "libx265" (x265 != null) "2.2")
    (fflag "libxavs" (xavs != null) null)
    #(enableFeature (xorg.libxcb != null) "libxcb") "2.5"
    (fflag "libxcb-shm" libxcbshmExtlib "2.5")
    (fflag "libxcb-xfixes" libxcbxfixesExtlib "2.5")
    (fflag "libxcb-shape" libxcbshapeExtlib "2.5")
    (fflag "libxvid" (xvidcore != null) null)
    (fflag "libzimg" (libzimg != null) "3.0")
    (fflag "libzmq" (zeromq4 != null) "2.0")
    #(fflag "libzvbi" (zvbi != null) "2.1")
    /**/"--disable-libzvbi"
    (fflag "lzma" (xz != null) "2.4")
    #(fflag "decklink" decklinkExtlib "2.2")
    /**/"--disable-decklink"
    (fflag "mediacodec" false "3.1") # android
    (fflag "netcdf" (netcdf != null) "3.0")
    (fflag "openal" (openal != null) null)
    #(fflag "opencl" (opencl != null) "2.2")
    /**/"--disable-opencl"
    # OpenGL requires libX11 for GLX
    (fflag "opengl" (mesa_noglu != null && xorg.libX11 != null) "2.2")
    (fflag "openssl" opensslExtlib null)
    #(fflag "schannel" (schannel != null) "3.0")
    /**/(fflag "schannel" false "3.0")
    (fflag "sdl" (SDL != null) "2.5")
    (fflag "securetransport" false "2.7")
    (fflag "x11grab" x11grabExtlib null)
    #(enableFeature (xorg.libX11 != null && xorg.libXv != null) "xlib") "2.3"
    (fflag "zlib" (zlib != null) null)
    /*
     *  Developer flags
     */
    (fflag "debug" debugDeveloper null)
    (fflag "optimizations" optimizationsDeveloper null)
    (fflag "extra-warnings" extraWarningsDeveloper null)
    (fflag "stripping" strippingDeveloper null)
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
