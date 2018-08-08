{ stdenv
, fetchFromGitHub
, fetchurl
, lib
, makeWrapper
, python2
, which

, alsa-lib
, avahi
, boost
, grpc
, ice
, libbsd
, libcap
, libsndfile
, libx11
, libxext
, libxfixes
, libxi
, opengl-dummy
, opus
, openssl
, portaudio
, protobuf-cpp
, pulseaudio_lib
, qt5
, rnnoise
, speech-dispatcher
, speex
, speexdsp
, xorgproto

, mumbleOverlay ? true
, releaseType ? "release"

, channel
, config
}:

/* FIXME: the build system defaults to proto2 while mumble uses proto3
          [libprotobuf WARNING google/protobuf/compiler/parser.cc:547]
          No syntax specified for the proto file: Mumble.proto. Please
          use 'syntax = "proto2";' or 'syntax = "proto3";' to specify a
          syntax version. (Defaulted to proto2 syntax.) */

assert (config == "mumble" || config == "murmur");

assert (releaseType == "release" || releaseType == "debug");

let
  inherit (lib)
    boolNo
    optionals
    optionalString;

  mumble-theme = fetchFromGitHub {
    version = 5;
    owner = "mumble-voip";
    repo = "mumble-theme";
    rev = "212f8e336d3c2b385c10a7462ceedb88919edd00";
    sha256 = "fca086c622b6cde4530647b5c3fa7b05e50adfdbb99705df54efbc6c18668b7f";
  };

  celt_mumble-src = fetchFromGitHub {
    version = 5;
    owner = "mumble-voip";
    repo = "celt-0.7.0";
    rev = "5a16cda6d78cda0cd14eb13c56c65d82724842e5";
    sha256 = "1a6de45d1a2ccf5d08596adc16bff3f9ec257e9fcba77504250f8d9bf0545166";
  };

  sources = {
    "git" = {
      fetchzipversion = 6;
      version = "2018-07-21";
      rev = "7c08da0b3fcfe6a6a78f42fe58dc7f34ce2f944c";
      sha256 = "9a5b8a22ff9016777f64379628b65eb8f6f94d85ef0124b4322d9f55d0d86709";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "${config}-${source.version}";

  src = fetchFromGitHub {
    version = source.fetchzipversion;
    owner = "mumble-voip";
    repo = "mumble";
    inherit (source)
      rev
      sha256;
  };

  nativeBuildInputs = [
    python2
  ] ++ optionals (config == "mumble") [
    makeWrapper
    qt5
  ] ++ optionals (config == "murmur") [
    which
  ];

  buildInputs = [
    avahi
    boost
    libbsd
    openssl
    protobuf-cpp
    qt5
  ] ++ optionals (config == "mumble") [
    alsa-lib
    libsndfile
    libx11
    libxext
    libxfixes
    libxi
    opengl-dummy
    opus
    portaudio
    pulseaudio_lib
    rnnoise
    speech-dispatcher
    speex
    speexdsp
    xorgproto
  ] ++ optionals (config == "murmur") [
    grpc
    ice
    libcap
  ];

  postPatch = ''
    mkdir -v 3rdparty-new/
  '' + optionalString (config == "mumble") ''
    export MUMBLE_PYTHON="${python2}/bin/python"
    patchShebangs ./scripts/rcc-depends.py

    # Remove unused reference to Celt 0.11
    sed -i main.pro \
      -e 's, 3rdparty/celt-0.11.0-build,,'

    # Hack mumble's version of celt back into the source tree.
    pushd 3rdparty-new/
      unpackFile '${celt_mumble-src}'
      celt_unpack_dir="$(
        find . -type d -regextype sed -regex '\./celt-0\.7\.0-[a-z0-9]\{40\}'
      )"
      mv -v "$celt_unpack_dir" celt-0.7.0-src/
    popd

    pushd themes/
      unpackFile '${mumble-theme}'
      mumble_theme_unpack_dir="$(
        find . -type d -regextype sed -regex '\./mumble-theme-[a-z0-9]\{40\}'
      )"
      mv -v "$mumble_theme_unpack_dir"/* Mumble/
    popd
  '' + optionalString (config == "murmur" && ice != null) ''
    sed -i 's,/usr,${ice},g' src/murmur/murmur_ice/murmur_ice.pro
  '' + ''
    sed -i src/CryptographicRandom.cpp \
      -e 's,#include "arc4random_uniform.h",#include <bsd/stdlib.h>,' \
      -e 's,mumble_arc4random,arc4random,g'
    sed -i '/arc4random_uniform.cpp/d' src/mumble.pri

    mv -v 3rdparty/celt-0.7.0-build/ 3rdparty-new/
    mv -v 3rdparty/qqbonjour-src/ 3rdparty-new/
    mv -v 3rdparty/smallft-src/ 3rdparty-new/

    # Remove the original 3rdparty directory to ensure vendored sources are
    # not used.
    rm -rv 3rdparty
    mv -v 3rdparty-new 3rdparty
  '';

  configureFlags = [
    "${releaseType}"
    "${boolNo (config == "mumble")}client"
    "${boolNo (config == "murmur")}server"
    "shared"
    "no-static"
    "no-g15"
    "dbus"
    "${boolNo (avahi != null)}bonjour"
    "embed-tango-icons"
    "no-static_qt_plugins"
    "packaged"
    "no-update"
    "no-embed-qt-translations"
    "${boolNo (speech-dispatcher != null)}speechd"
  ] ++ optionals (config == "mumble") [
    "${boolNo (alsa-lib != null)}alsa"
    "no-directsound"
    "no-oss"
    "${boolNo (portaudio != null)}portaudio"
    "no-wasapi"
    "no-jackaudio"
    "no-asio"  # TODO: asio support, ASIOInput.h
    "no-bundled-speex"
    "no-sbcelt"
    "bundled-celt"
    "opus"
    "no-bundled-opus"
    "rnnoise"
    "no-bundled-rnnoise"
    "vorbis-recording"
    "${boolNo mumbleOverlay}overlay"
    "no-qt4-legacy-compat"
  ] ++ optionals (config == "murmur") [
    "${boolNo (ice != null)}ice"
    "${boolNo (grpc != null)}grpc"
    "qssldiffiehellmanparameters"
  ];

  configurePhase = ''
    echo "configureFlags: $configureFlags"
    export QT_SELECT=qt5
    qmake ./main.pro \
      -recursive \
      "CONFIG += $configureFlags" \
      "DEFINES += PLUGIN_PATH=$out/lib"
  '';

  makeFlags = [
    "${releaseType}"
  ];

  NIX_LDFLAGS = "-lbsd";

  installPhase = ''
    mkdir -pv "$out"/{lib,bin}
    find ${releaseType} -type f -not -name \*.\* -exec cp -v {} $out/bin \;
    find ${releaseType} -type f -name \*.\* -exec cp -v {} $out/lib \;

    mkdir -pv $out/share/man/man1
    cp -v man/mum* $out/share/man/man1
  '' + optionalString (config == "mumble") (
      optionalString mumbleOverlay ''
      install -D -m755 -v 'scripts/mumble-overlay' "$out/bin/mumble-overlay"
      sed -i "$out/bin/mumble-overlay" \
        -e "s,/usr/lib,$out/lib,g"
    '' + ''
      install -D -m644 -v 'scripts/mumble.desktop' \
        "$out/share/applications/mumble.desktop"

      mkdir -p $out/share/icons/hicolor/scalable/apps
      install -D -m644 -v 'icons/mumble.svg' "$out/share/icons/mumble.svg"
      ln -sv \
        "$out/share/icon/mumble.svg" \
        "$out/share/icons/hicolor/scalable/apps"
    ''
  );

  meta = with lib; {
    description = "Low-latency, high quality voice chat software";
    homepage = http://mumble.sourceforge.net/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
