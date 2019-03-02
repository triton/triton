{ stdenv
, fetchFromGitHub
, fetchTritonPatch
, fetchurl
, lib
, nasm
, perl
, texinfo

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
, ffserverProgram ? false  # DEPRECATED
, qtFaststartProgram ? true
/*
 *  Library options
 */
, avcodecLibrary ? true
, avdeviceLibrary ? true
, avfilterLibrary ? true
, avformatLibrary ? true
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
, aomedia
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
, libcdio
, libcdio-paranoia
, libdc1394
, libdrm
#, libiec61883, libavc1394
, libgcrypt
, libmodplug
, libmysofa ? null
, libnppSupport ? false
, libogg
, libraw1394
, librsvg
, libsndio ? null
, libssh
, libtheora
, libva
, libvdpau
, libvorbis
, libvpx
, libwebp
, libx11
, libxcb
, libxcbshmExtlib ? true
, libxcbxfixesExtlib ? true
, libxcbshapeExtlib ? true
, libxext
, libxfixes
, libxml2
, libxv
, mfx-dispatcher
, mmal ? null
, nv-codec-headers
, nvidia-cuda-toolkit
, nvidia-drivers
, openal
#, opencl
#, opencore-amr
, opencv
, opengl-dummy
, openh264
, openjpeg
, openssl
, opus
, pulseaudio_lib
, rtmpdump
, rubberband
#, libquvi
, samba_client
, sdl
#, shine
, snappy
, soxr
, speex
#, srt  # TODO: https://github.com/Haivision/srt
, tesseract
#, twolame
#, utvideo
, v4l_lib
#, vapoursynth  # FIXME: recursive dependency
, vid-stab
#, vo-aacenc
, vo-amrwbenc ? null
, wavpack
, x264
, x265
, xavs
, xorgproto
, xvidcore
, xz
, zeromq4
, zimg
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

  inherit (stdenv)
    targetSystem;

  inherit (lib)
    boolEn
    elem
    optional
    optionals
    optionalString
    platforms
    versionOlder;

  sources = {
    "3.4" = {
      version = "3.4.5";
      multihash = "QmZAz1VmeMdWnG9UAzUcwQiEMB5DWZP9SMc6iZPGmEfY2a";
      sha256 = "741cbd6394eaed370774ca4cc089eaafbc54d0824b9aa360d4b3b0cbcbc4a92c";
    };
    "4.0" = {
      version = "4.0.2";
      multihash = "QmV86CsDaQMo5iSM9HSmPQC79YmNNgj5XQ1Lv18JZQqvHR";
      sha256 = "a95c0cc9eb990e94031d2183f2e6e444cc61c99f6f182d1575c433d62afb2f97";
    };
    "9.9" = {  # Git
      fetchzipversion = 6;
      version = "2019.02.14";
      rev = "9e1e5213933dfed529f0cecac7304236a786177e";
      sha256 = "daeb1af827a9a3331a99efb11bf57ee06dcc65eaa4fb0438469caba52d7f2620";
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
  || libcdio != null
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
  #|| libvmaf != null
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
  && sdl != null;
assert ffprobeProgram ->
  avcodecLibrary
  && avformatLibrary;
assert ffserverProgram -> avformatLibrary;  # DEPRECATED
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
assert postprocLibrary -> avutilLibrary;
assert swresampleLibrary -> soxr != null;
assert swscaleLibrary -> avutilLibrary;
/*
 *  External libraries
 */
assert flite != null -> alsa-lib != null;
assert libxcbshmExtlib -> libxcb != null;
assert libxcbxfixesExtlib -> libxcb != null;
assert libxcbshapeExtlib -> libxcb != null;
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
        version = source.fetchzipversion;
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
    nasm
  ];

  buildInputs = [
    alsa-lib
    aomedia
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
    libcdio
    libcdio-paranoia
    libdc1394
    libdrm
    libgcrypt
    libmodplug
    libogg
    libraw1394
    librsvg
    libssh
    libtheora
    libva
    libvdpau
    libvorbis
    libvpx
    libwebp
    libx11
    libxcb
    libxext
    libxfixes
    libxml2
    libxv
    #xorg.libXvMC
    mfx-dispatcher
    nvidia-cuda-toolkit
    nvidia-drivers
    openal
    opengl-dummy
    openh264
    openjpeg
    opus
    pulseaudio_lib
    rtmpdump
    rubberband
    samba_client
    sdl
    soxr
    snappy
    speex
    #srt
    tesseract
    v4l_lib
    #vapoursynth
    vid-stab
    wavpack
    x264
    x265
    xavs
    xorgproto
    xvidcore
    xz
    zeromq4
    zimg
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
    "--${boolEn smallBuild}-small"
    "--${boolEn runtimeCpuDetectBuild}-runtime-cpudetect"
    "--${boolEn grayBuild}-gray"
    "--${boolEn swscaleAlphaBuild}-swscale-alpha"
    #"--disable-autodetect"
    "--${boolEn hardcodedTablesBuild}-hardcoded-tables"
    "--${boolEn safeBitstreamReaderBuild}-safe-bitstream-reader"
    "--enable-pthreads"
    "--disable-w32threads"  # Windows
    "--disable-os2threads"  # OS/2
    "--${boolEn networkBuild}-network"
    "--${boolEn pixelutilsBuild}-pixelutils"
    /*
     *  Program flags
     */
    "--${boolEn ffmpegProgram}-ffmpeg"
    "--${boolEn ffplayProgram}-ffplay"
    "--${boolEn ffprobeProgram}-ffprobe"
    (deprfflag "--${boolEn ffserverProgram}-ffserver" null "3.4")
    /*
     *  Library flags
     */
    "--${boolEn avcodecLibrary}-avcodec"
    "--${boolEn avdeviceLibrary}-avdevice"
    "--${boolEn avfilterLibrary}-avfilter"
    "--${boolEn avformatLibrary}-avformat"
    "--disable-avresample"
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
    (fflag "--disable-amf" "4.0")
    "--disable-audiotoolbox"  # macOS
    (deprfflag "--${boolEn (
      nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-cuda" null "3.4")
    "--${boolEn (
      nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-cuda-sdk"
    (deprfflag "--${boolEn (
      nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-cuvid" null "3.4")
    (fflag "--${boolEn (
      nv-codec-headers != null
      && nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-cuvid" "4.0")
    "--disable-d3d11va"  # Windows
    "--disable-dxva2"  # Windows
    (fflag "--${boolEn (
      nv-codec-headers != null
      && nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-ffnvcodec" "4.0")
    "--${boolEn (libdrm != null)}-libdrm"
    "--${boolEn (mfx-dispatcher != null)}-libmfx"
    "--${boolEn libnppSupport}-libnpp"
    #"--${boolEn (mmal != null)}-mmal"
    /**/"--disable-mmal"
    (deprfflag "--${boolEn (
      nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-nvenc" null "3.4")
    (fflag "--${boolEn (
      nv-codec-headers != null
      && nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-nvenc" "4.0")
    (fflag "--${boolEn (
      nv-codec-headers != null
      && nvidia-cuda-toolkit != null
      && nvidia-drivers != null)}-nvdec" "4.0")
    /**/"--disable-omx"
    /**/"--disable-omx-rpi"
    /**/"--disable-rkmpp"
    "--${boolEn (libva != null)}-vaapi"
    (deprfflag "--disable-vda" null "3.4")  # macOS
    "--${boolEn (libvdpau != null)}-vdpau"
    "--disable-videotoolbox"  # macOS
    # Undocumented
    # FIXME
    #"--${boolEn (xorg.libXvMC != null)}-xvmc"
    "--disable-xvmc"
    /*
     *  External libraries
     */
    "--${boolEn (alsa-lib != null)}-alsa"
    "--disable-appkit"  # macOS
    "--disable-avfoundation"  # macOS
    #"--${boolEn (avisynth != null)}-avisynth"
    /**/"--disable-avisynth"
    "--${boolEn (bzip2 != null)}-bzlib"
    "--disable-coreimage"  # macOS
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
    (deprfflag "--${boolEn (jack2_lib != null)}-jack" null "3.4")
    "--${boolEn (jni != null)}-jni"
    "--${boolEn (ladspa-sdk != null)}-ladspa"
    (fflag "--${boolEn (aomedia != null)}-libaom" "4.0")
    /**/(fflag "--disable-libaribb24" "4.1")
    "--${boolEn (libass != null)}-libass"
    "--${boolEn (libbluray != null)}-libbluray"
    "--${boolEn (libbs2b != null)}-libbs2b"
    "--${boolEn (libcaca != null)}-libcaca"
    "--${boolEn (celt != null)}-libcelt"
    "--${boolEn (libcdio != null && libcdio-paranoia != null)}-libcdio"
    /**/(fflag "--disable-libcodec2" "4.0")
    /**/(fflag "--disable-libdav1d" "4.1")
    /**/(fflag "--disable-libdavs2" "4.1")
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
    (fflag "--${boolEn (jack2_lib != null)}-libjack" "4.0")
    /**/(fflag "--disable-libklvanc" "4.1")
    "--${boolEn (kvazaar != null)}-libkvazaar"
    /**/(fflag "--disable-liblensfun" "4.1")
    "--${boolEn (libmodplug != null)}-libmodplug"
    "--${boolEn (lame != null)}-libmp3lame"
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
    "--${boolEn (librsvg != null)}-librsvg"
    "--${boolEn (rubberband != null)}-librubberband"
    "--${boolEn (rtmpdump != null)}-librtmp"
    #"--${boolEn (shine != null)}-libshine"
    /**/"--disable-libshine"
    "--${boolEn (samba_client != null)}-libsmbclient"
    "--${boolEn (snappy != null)}-libsnappy"
    "--${boolEn (soxr != null)}-libsoxr"
    "--${boolEn (speex != null)}-libspeex"
    /**/(fflag "--disable-libsrt" "4.0")
    "--${boolEn (libssh != null)}-libssh"
    /**/(fflag "--disable-libtensorflow" "4.1")
    #"--${boolEn (tesseract != null)}-libtesseract"
    /**/"--disable-libtesseract"
    "--${boolEn (libtheora != null && libogg != null)}-libtheora"
    /**/(fflag "--disable-libtls" "4.0")  # libressl
    #"--${boolEn (twolame != null)}-libtwolame"
    /**/"--disable-libtwolame"
    "--${boolEn (v4l_lib != null)}-libv4l2"
    (deprfflag "--${boolEn (v4l_lib != null)}-v4l2_m2m" null "3.4")
    (fflag "--${boolEn (v4l_lib != null)}-v4l2-m2m" "4.0")
    "--${boolEn (vid-stab != null)}-libvidstab"
    /**/"--disable-libvmaf"
    "--${boolEn (vo-amrwbenc != null)}-libvo-amrwbenc"
    "--${boolEn (libvorbis != null)}-libvorbis"
    "--${boolEn (libvpx != null)}-libvpx"
    "--${boolEn (wavpack != null)}-libwavpack"
    "--${boolEn (libwebp != null)}-libwebp"
    "--${boolEn (x264 != null)}-libx264"
    "--${boolEn (x265 != null)}-libx265"
    "--${boolEn (xavs != null)}-libxavs"
    /**/(fflag "--disable-libxavs2" "4.1")
    #"--${boolEn (libxcb != null)}-libxcb"
    "--${boolEn libxcbshmExtlib}-libxcb-shm"
    "--${boolEn libxcbxfixesExtlib}-libxcb-xfixes"
    "--${boolEn libxcbshapeExtlib}-libxcb-shape"
    "--${boolEn (xvidcore != null)}-libxvid"
    "--${boolEn (libxml2 != null)}-libxml2"
    "--${boolEn (zimg != null)}-libzimg"
    "--${boolEn (zeromq4 != null)}-libzmq"
    #"--${boolEn (zvbi != null)}-libzvbi"
    /**/"--disable-libzvbi"
    /**/(fflag "--disable-lv2" "4.0")
    "--${boolEn (xz != null)}-lzma"
    #"--${boolEn decklinkExtlib}-decklink"
    /**/"--disable-decklink"
    /**/"--disable-libndi_newtek"
    #/**/(fflag "--disable-mbedtls" "4.1")
    "--disable-mediacodec"  # android
    "--${boolEn (libmysofa != null)}-libmysofa"
    "--${boolEn (openal != null)}-openal"
    #"--${boolEn (opencl != null)}-opencl"
    /**/"--disable-opencl"
    "--${boolEn (opengl-dummy != null && opengl-dummy.glx)}-opengl"
    "--${boolEn (openssl != null)}-openssl"
    /**/"--disable-sndio"
    "--disable-schannel"  # Windows
    "--${boolEn (sdl != null)}-sdl"
    "--${boolEn (sdl != null)}-sdl2"
    "--disable-securetransport"
    #(fflag "--${boolEn (vapoursynth != null)}-vapoursynth" "4.1")
    /**/(fflag "--disable-vapoursynth" "4.1")
    #"--${boolEn (libx11 != null && libxv != null)}-xlib"
    "--${boolEn (zlib != null)}-zlib"
    /*
     *  Developer flags
     */
    "--${boolEn debugDeveloper}-debug"
    "--${boolEn optimizationsDeveloper}-optimizations"
    "--${boolEn extraWarningsDeveloper}-extra-warnings"
    "--${boolEn strippingDeveloper}-stripping"
    "--${boolEn (elem targetSystem platforms.linux)}-linux-perf"
  ] ++ optionals (alsa-lib != null && flite != null) [
    # Flite requires alsa but the configure test under specifies
    # dependencies and fails without -lasound.
    "--extra-ldflags=-lasound"
  ];

  # For debugging the configure script
  #configurePhase = ''
  #  ./configure $configureFlags || {
  #    cat ffbuild/config.log
  #    return 1
  #  }
  #'';

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
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "FCF9 86EA 15E6 E293 A564  4F10 B432 2F04 D676 58D8";
      };
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
