{ stdenv
, fetchpatch
, fetchurl
, lib
, scons

, chromaprint
, faad2
, ffmpeg
, fftw_double
, flac
, libid3tag
, libmad
, libmodplug
, libshout
, libsndfile
, libusb
, libvorbis
, libx11
, mesa_noglu
, mp4v2
, opus
, opusfile
, portaudio
, portmidi
, protobuf-cpp
, qt5
, rubberband
, soundtouch
, sqlite
, taglib
, vamp-plugin-sdk
, wavpack
}:

let
  inherit (lib)
    bool01;
in
stdenv.mkDerivation rec {
  name = "mixxx-2.0.0";

  src = fetchurl {
    url = "https://downloads.mixxx.org/${name}/${name}-src.tar.gz";
    sha256 = "e1b8f33bba35046608578095ed3209967034579252d84c99e6bc03ec030f676d";
  };

  nativeBuildInputs = [
    scons
  ];

  buildInputs = [
    chromaprint
    faad2
    ffmpeg
    fftw_double
    flac
    libid3tag
    libmad
    libmodplug
    libshout
    libsndfile
    libusb
    libvorbis
    libx11
    mesa_noglu
    mp4v2
    opus
    opusfile
    portaudio
    portmidi
    protobuf-cpp
    qt5
    rubberband
    soundtouch
    sqlite
    taglib
    vamp-plugin-sdk
    wavpack
  ];

  patches = [
    (fetchpatch {
      url = "https://github.com/mixxxdj/mixxx/commit/"
        + "51d95ba58d99309f439cb7e2d1285cfb33aa0f63.patch";
      sha256 = "18624e01632a2a27329ee692991a61ec9944f3a7f6c2ad3b0345429c1727b0c8";
    })
    (fetchpatch {
      url = "https://github.com/mixxxdj/mixxx/commit/"
        + "51d95ba58d99309f439cb7e2d1285cfb33aa0f63.patch";
      sha256 = "18624e01632a2a27329ee692991a61ec9944f3a7f6c2ad3b0345429c1727b0c8";
    })
  ];

  postPatch = ''
    sed -i build/depends.py \
      -e 's/"which /"type -P /'
  '';

  sconsFlags = [
    "build=release"
    "qt5=1"
    "qtdir=${qt5}"

    "opengles=0"
    "hss1394=0"
    "hid=${bool01 (libusb != null)}"
    "bulk=${bool01 (libusb != null)}"
    "mad=${bool01 (libmad != null)}"
    "coreaudio=0"
    "mediafoundation=0"
    "ipod=0"
    "vinylcontrol=1"
    "vamp=${bool01 (vamp.vampSDK != null)}"
    "modplug=${bool01 (libmodplug != null)}"
    "faad=${bool01 (faad2 != null)}"
    "wv=${bool01 (wavpack != null)}"
    "color=0"
    "asan=0"
    "perftools=0"
    "asmlib=0"
    "buildtime=0"
    "qtdebug=0"
    "verbose=0"
    "profiling=0"
    "test=0"
    "shoutcast=${bool01 (libshout != null)}"
    "opus=${bool01 (opus != null)}"
    "ffmpeg=${bool01 (ffmpeg != null)}"
    "optimize=portable"
    "autodjcrates=1"
    "macappstore=0"
    "localecompare=1"
  ];

  buildPhase = ''
    runHook 'preBuild'
    mkdir -p "$out"
    scons \
      -j$NIX_BUILD_CORES -l$NIX_BUILD_CORES \
      $sconsFlags "prefix=$out"
    runHook 'postBuild'
  '';

  installPhase = ''
    runHook 'preInstall'
    scons $sconsFlags "prefix=$out" install
    runHook 'postInstall'
  '';

  meta = with lib; {
    description = "Digital DJ mixing software";
    homepage = "http://mixxx.org/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
