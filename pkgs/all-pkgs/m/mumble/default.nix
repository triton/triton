{ stdenv
, fetchgit
, fetchurl
, python2
, which

, alsa-lib
, avahi
, boost
, grpc
, jack2_lib
, libcap
, libsndfile
, opengl-dummy
, opus
, openssl_1-0-2
, portaudio
, protobuf-cpp
, pulseaudio_lib
, qt4
, qt5
, speech-dispatcher
, speex
, speexdsp
, xorg

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
  inherit (stdenv.lib)
    boolNo
    optional
    optionals
    optionalString;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "${config}-${source.version}";

  src =
    if channel == "git" then
      fetchgit {
        version = source.fetchzipversion;
        url = "https://github.com/mumble-voip/mumble";
        inherit (source)
          rev
          sha256;
      }
    else
      fetchurl {
        url = "https://github.com/mumble-voip/mumble/releases/download/"
          + "${source.version}/mumble-${source.version}.tar.gz";
        inherit (source) sha256;
      };

  nativeBuildInputs = [
    python2
  ] ++ optionals (config == "mumble") [
    qt4
    qt5
  ] ++ optionals (config == "murmur") [
    which
  ];

  buildInputs = [
    avahi
    boost
    openssl_1-0-2
    protobuf-cpp
    qt4
    qt5
  ] ++ optionals (config == "mumble") [
    alsa-lib
    jack2_lib
    libsndfile
    opengl-dummy
    opus
    portaudio
    pulseaudio_lib
    speech-dispatcher
    speex
    speexdsp
    xorg.fixesproto
    xorg.inputproto
    xorg.libX11
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.xproto
  ] ++ optionals (config == "murmur") [
    grpc
    libcap
  ];

  patches = optionals (jack2_lib != null) [
    ./mumble-jack-support.patch
  ];

  postPatch = optionalString (config == "mumble") (
    ''
      export MUMBLE_PYTHON="${python2}/bin/python"
    '' + optionalString (channel != "1.2") ''
      patchShebangs ./scripts/rcc-depends.py
    ''
  );

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
    # static_qt_plugins
    "no-static_qt_plugins"
    "packaged"
    "no-update"
    "no-embed-qt-translations"
    "${boolNo (speech-dispatcher != null)}speechd"
  ] ++ optionals (config == "mumble") [
    "${boolNo (alsa-lib != null)}alsa"
    "no-directsound"
    "${boolNo (jack2_lib != null)}jackaudio"
    "no-oss"
    "${boolNo (portaudio != null)}portaudio"
    "no-wasapi"
    # TODO: asio support, ASIOInput.h
    "no-asio"
    "no-bundled-speex"
    # sbcelt
    "bundled-celt"
    "${boolNo (opus != null)}opus"
    "no-bundled-opus"
    "vorbis-recording"
    "${boolNo mumbleOverlay}overlay"
    "${boolNo (qt5 == null)}qt4-legacy-compat"
  ] ++ optionals (config == "murmur") [
    "no-ice"
    "${boolNo (grpc != null)}grpc"
    "qssldiffiehellmanparameters"
  ];

  configurePhase = ''
    echo "configureFlags: $configureFlags"
    export QT_SELECT=${if (qt5 != null) then "qt5" else "qt4"}
    qmake ./main.pro \
      -recursive \
      "CONFIG += $configureFlags" \
      "DEFINES += PLUGIN_PATH=$out/lib"
  '';

  makeFlags = [
    "${releaseType}"
  ];

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

  meta = with stdenv.lib; {
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
