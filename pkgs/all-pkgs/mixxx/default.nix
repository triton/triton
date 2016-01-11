{ stdenv
, fetchurl
, scons

, chromaprint
, faad2
, ffmpeg
, fftw
, flac
, libid3tag
, libmad
, libmodplug
, libopus
, libshout
, libsndfile
, libusb1
, libvorbis
, mesa_noglu
, mp4v2
, opusfile
, portaudio
, portmidi
, protobuf
, qt5
, rubberband
, soundtouch
, sqlite
, taglib
, vampSDK
, wavpack
, xorg
}:

with {
  inherit (stdenv.lib)
    scFlag;
};

stdenv.mkDerivation rec {
  name = "mixxx-${version}";
  version = "2.0.0";

  src = fetchurl {
    url = "https://downloads.mixxx.org/${name}/${name}-src.tar.gz";
    sha256 = "0vb71w1yq0xwwsclrn2jj9bk8w4n14rfv5c0aw46c11mp8xz7f71";
  };

  postPatch = ''
    sed -e 's/"which /"type -P /' -i build/depends.py
  '';

  sconsFlags = [
    "build=release"
    "qt5=1"
    "qtdir=${qt5.qtbase}"

    "opengles=0"
    "hss1394=0"
    (scFlag "hid" (libusb1 != null))
    (scFlag "bulk" (libusb1 != null))
    (scFlag "mad" (libmad != null))
    "coreaudio=0"
    "mediafoundation=0"
    "ipod=0"
    "vinylcontrol=1"
    (scFlag "vamp" (vampSDK != null))
    (scFlag "modplug" (libmodplug != null))
    (scFlag "faad" (faad2 != null))
    (scFlag "wv" (wavpack != null))
    "color=0"
    "asan=0"
    "perftools=0"
    "asmlib=0"
    "buildtime=0"
    "qtdebug=0"
    "verbose=0"
    "profiling=0"
    "test=0"
    (scFlag "shoutcast" (libshout != null))
    (scFlag "opus" (libopus != null))
    (scFlag "ffmpeg" (ffmpeg != null))
    "optimize=portable"
    "autodjcrates=1"
    "macappstore=0"
    "localecompare=1"
  ];

  nativeBuildInputs = [
    scons
  ];

  buildInputs = [
    chromaprint
    faad2
    ffmpeg
    fftw
    flac
    libid3tag
    libmad
    libmodplug
    libopus
    libshout
    libsndfile
    libusb1
    libvorbis
    mesa_noglu
    mp4v2
    opusfile
    portaudio
    portmidi
    protobuf
    qt5.qtbase
    qt5.qtscript
    qt5.qtsvg
    qt5.qttranslations
    qt5.qtxmlpatterns
    rubberband
    soundtouch
    sqlite
    taglib
    vampSDK
    wavpack
    xorg.libX11
  ];

  buildPhase = ''
    runHook preBuild
    mkdir -p "$out"
    scons \
      -j$NIX_BUILD_CORES -l$NIX_BUILD_CORES \
      $sconsFlags "prefix=$out"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    scons $sconsFlags "prefix=$out" install
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Digital DJ mixing software";
    homepage = "http://mixxx.org/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
