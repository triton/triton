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
  , cudatoolkit
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
#, libmfx
, libmodplug
#, libnut
, libogg
, libopus
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
, openjpeg_1
, opensslExtlib ? false, openssl
, pulseaudio_lib
, rtmpdump
, rubberband
#, libquvi
, samba
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

, channel ? null
, full ? false
}:

let
  inherit (builtins)
    compareVersions;
  inherit (stdenv.lib)
    enFlag
    optional
    optionals
    optionalString
    versionOlder;
  inherit (builtins.getAttr channel (import ./sources.nix))
    versionMajor
    versionMinor
    sha256;
in

assert channel != null;

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
  || samba != null
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
  samba != null
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
  branch =
    if channel == "9" then
      "9.9"
    else
      channel + "." + versionMajor;
  # Minimum/maximun/matching version
  reqMin = v: (compareVersions v branch != 1);
  reqMax = v: (compareVersions branch v != 1);
  reqMatch = v: (compareVersions v branch == 0);

  # Usage:
  # f - Configure flags w/o --enable/disable
  # b - Boolean: (some-pkg !=null) or someFlag
  # v - Version that the configure option was added
  fflag = f: b: v:
    if v == null || reqMin v  then
      enFlag f b null
    else
      null;
  deprfflag = f: b: vmin: vmax:
    if reqMin vmin && reqMax vmax then
      enFlag f b null
    else
      null;
in

stdenv.mkDerivation rec {
  name = "ffmpeg-${version}";
  version =
    if channel == "9" then
      versionMajor
    else
      branch + "." + versionMinor;

  src =
    if channel == "9" then
      fetchFromGitHub {
        owner = "ffmpeg";
        repo = "ffmpeg";
        rev = versionMinor;
        inherit sha256;
      }
    else
      fetchurl {
        url = "https://www.ffmpeg.org/releases/${name}.tar.xz";
        inherit sha256;
      };

  nativeBuildInputs = [
    perl
    texinfo
    yasm
  ];

  buildInputs = [
    alsa-lib
    bzip2
    fontconfig
    freetype
    gnutls
    lame
    libass
    libbluray
    libgcrypt
    libogg
    libopus
    libtheora
    libva
    libvdpau
    libvorbis
    libvpx
    mesa_noglu
    pulseaudio_lib
    SDL
    soxr
    speex
    v4l_lib
    x264
    x265
    xorg.libX11
    xvidcore
    xz
    zlib
  ] ++ optionals full ([
    celt
    #chromaprint
    frei0r
    fribidi
    gmp
    game-music-emu
    gsm
    jack2_lib
    ladspaH
    libbs2b
    libcaca
    libdc1394
    libmodplug
    libraw1394
    libssh
    libwebp
    openal
    openjpeg_1
    rtmpdump
    rubberband
    samba
    schroedinger
    snappy
    tesseract
    vid-stab
    wavpack
    xavs
    xorg.libxcb
    xorg.libXext
    xorg.libXfixes
    xorg.libXv
    zeromq4
  ] ++ optionals nonfreeLicensing [
    cudatoolkit
    faac
    fdk_aac
    openssl
    nvidia-video-codec-sdk
  ]);

  # TODO: figure out when this was fixed, assuming is was
  postPatch = ''
    patchShebangs .
  '' + optionalString (versionOlder "2.8" branch) ''
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
    "--disable-thumb"
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
    "--disable-w32threads"
    "--disable-os2threads"
    (fflag "network" networkBuild null)
    (fflag "pixelutils" pixelutilsBuild null)
    /*
     *  Program flags
     */
    (fflag "ffmpeg" ffmpegProgram null)
    (fflag "ffplay" ffplayProgram null)
    (fflag "ffprobe" ffprobeProgram null)
    (fflag "ffserver" (ffserverProgram && full) null)
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
    "--disable-d3d11va"
    "--disable-dxva2"
    (fflag "vaapi" (libva != null) null)
    "--disable-vda"
    (fflag "vdpau" (libvdpau != null) null)
    "--disable-videotoolbox"
    # Undocumented
    "--enable-xvmc"
    /*
     *  External libraries
     */
    (fflag "audiotoolbox" false "3.1")
    #(fflag "avisynth" (avisynth != null) null)
    "--disable-avisynth"
    (fflag "bzlib" (bzip2 != null) null)
    (fflag "cuda" (cudaExtLib && full) "3.1")
    # Recursive dependency
    #(fflag "chromaprint" (chromaprint != null) "3.0")
    /**/(fflag "chromaprint" false "3.0")
    # Undocumented (broadcom)
    #(fflag "crystalhd" (crystalhd != null) null)
    "--disable-crystalhd"
    (fflag "fontconfig" (fontconfig != null) null)
    (fflag "frei0r" (frei0r != null && full) null)
    # Undocumented before 3.0
    (fflag "gcrypt" (libgcrypt != null) "3.0")
    (fflag "gmp" (gmp != null && full) "3.0")
    (fflag "gnutls" (
      gnutls != null
      && !opensslExtlib) null)
    (fflag "iconv" (stdenv.cc.libc != null) null)
    (fflag "jni" (jni != null && full) "3.1")
    (fflag "ladspa" (ladspaH != null && full) "2.1")
    (deprfflag "libaacplus" false "0.7" "2.8")
    (fflag "libass" (libass != null) null)
    (fflag "libbluray" (libbluray != null) null)
    (fflag "libbs2b" (libbs2b != null && full) "2.3")
    (fflag "libcaca" (libcaca != null && full) null)
    (fflag "libcelt" (celt != null && full) null)
    #(fflag "libcdio" (libcdio != null) null)
    "--disable-libcdio"
    (fflag "libdc1394" (
      libdc1394 != null
      && libraw1394 != null && full) null)
    # Undocumented
    (deprfflag "libdcadec" (dcadec != null && full) "2.7" "3.0")
    (fflag "libfaac" (faacExtlib && full) null)
    (fflag "libfdk-aac" (fdkaacExtlib && full) null)
    #(fflag "libflite" (flite != null) null)
    "--disable-libflite"
    (fflag "libfreetype" (freetype != null) null)
    (fflag "libfribidi" (fribidi != null && full) "2.3")
    (fflag "libgme" (game-music-emu != null && full) "2.2")
    #(fflag "libgsm" (gsm != null && full) null)
    "--disable-libgsm"
    #(fflag "libiec61883" (
    #  libiec61883 != null
    #  && libavc1394 != null
    #  && libraw1394 != null && full) null)
    "--disable-libiec61883"
    #(fflag "libilbc" (ilbc != null && full) null)
    "--disable-libilbc"
    (fflag "libkvazaar" (kvazaar != null && full) "2.8")
    #(fflag "libmfx" (libmfx != null && full) "2.6")
    "--disable-libmfx"
    (fflag "libmodplug" (libmodplug != null && full) null)
    (fflag "libmp3lame" (lame != null) null)
    #(fflag "libnut" (libnut != null && full) null)
    "--disable-libnut"
    #(fflag "libnpp" (npp != null && full) "3.1")
    /**/(fflag "libnpp" false "3.1")
    #(fflag "libopencore-amrnb" (opencore-amr != null && full) null)
    "--disable-libopencore-amrnb"
    #(fflag "libopencore-amrwb" (opencore-amr != null && full) null)
    "--disable-libopencore-amrwb"
    #(fflag "libopencv" (opencv != null && full) null)
    "--disable-libopencv"
    #(fflag "libopenh264" (openh264 != null) "2.6")
    "--disable-libopenh264"
    (fflag "libopenjpeg" (openjpeg_1 != null && full) null)
    (fflag "libopus" (libopus != null) null)
    (fflag "libpulse" (pulseaudio_lib != null) null)
    (deprfflag "libquvi" false "2.0" "2.8")
    (fflag "librubberband" (rubberband != null && full) "3.0")
    (fflag "librtmp" (rtmpdump != null && full) null)
    (fflag "libschroedinger" (schroedinger != null && full) null)
    #(fflag "libshine" (shine != null && full) "2.0")
    "--disable-libshine"
    (fflag "libsmbclient" (samba != null && full) "2.3")
    (fflag "libsnappy" (snappy != null && full) "2.8")
    (fflag "libsoxr" (soxr != null) null)
    (fflag "libspeex" (speex != null) null)
    (fflag "libssh" (libssh != null && full) "2.1")
    #(fflag "libtesseract" (tesseract != null && full) "3.0")
    /**/(fflag "libtesseract" false "3.0")
    (fflag "libtheora" (libtheora != null) null)
    #(fflag "libtwolame" (twolame != null && full) null)
    "--disable-libtwolame"
    #(fflag "libutvideo" (utvideo != null && full) null)
    "--disable-libutvideo"
    (fflag "libv4l2" (v4l_lib != null) null)
    (fflag "libvidstab" (vid-stab != null && full) "2.2")
    (deprfflag "libvo-aacenc" false "0.6" "2.8")
    (fflag "libvo-amrwbenc" (vo-amrwbenc != null && full) null)
    (fflag "libvorbis" (libvorbis != null) null)
    (fflag "libvpx" (libvpx != null) null)
    (fflag "libwavpack" (wavpack != null && full) "2.0")
    (fflag "libwebp" (libwebp != null && full) "2.2")
    (fflag "libx264" (x264 != null) null)
    (fflag "libx265" (x265 != null) "2.2")
    (fflag "libxavs" (xavs != null && full) null)
    #(enableFeature (xorg.libxcb != null && full) "libxcb") "2.5"
    (fflag "libxcb-shm" (libxcbshmExtlib && full) "2.5")
    (fflag "libxcb-xfixes" (libxcbxfixesExtlib && full) "2.5")
    (fflag "libxcb-shape" (libxcbshapeExtlib && full) "2.5")
    (fflag "libxvid" (xvidcore != null) null)
    (fflag "libzimg" (libzimg != null && full) "3.0")
    (fflag "libzmq" (zeromq4 != null && full) "2.0")
    #(fflag "libzvbi" (zvbi != null && full) "2.1")
    "--disable-libzvbi"
    (fflag "lzma" (xz != null) "2.4")
    #(fflag "decklink" (decklinkExtlib && full) "2.2")
    "--disable-decklink"
    (fflag "mediacodec" false "3.1") # android
    #(fflag "mmal" (mmal != null && full) "2.7")
    "--disable-mmal"
    (fflag "netcdf" (netcdf != null && full) "3.0")
    (fflag "nvenc" (nvencExtLib && full) "2.6")
    (fflag "openal" (openal != null && full) null)
    #(fflag "opencl" (opencl != null && full) "2.2")
    "--disable-opencl"
    # OpenGL requires libX11 for GLX
    (fflag "opengl" (mesa_noglu != null && xorg.libX11 != null) "2.2")
    (fflag "openssl" (opensslExtlib && full) null)
    #(fflag "schannel" (schannel != null && full) "3.0")
    /**/(fflag "schannel" false "3.0")
    (fflag "sdl" (SDL != null) "2.5")
    (fflag "securetransport" false "2.7")
    (fflag "x11grab" (x11grabExtlib && full) null)
    #(enableFeature (xorg.libX11 != null && xorg.libXv != null && full) "xlib") "2.3"
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
