{ stdenv
, fetchgit
, fetchurl
, python

, alsa-lib
, avahi
, boost
, ice
, jack2_lib
, libcap
, libsndfile
, mesa_noglu
, opus
, qt4
, qt5
, openssl
, portaudio
, protobuf-cpp
, pulseaudio_lib
, speechd
, speex
, xorg

, mumbleOverlay ? true

, channel
, config
}:

/* FIXME: the build system defaults to proto2 while mumble uses proto3
          [libprotobuf WARNING google/protobuf/compiler/parser.cc:547]
          No syntax specified for the proto file: Mumble.proto. Please
          use 'syntax = "proto2";' or 'syntax = "proto3";' to specify a
          syntax version. (Defaulted to proto2 syntax.) */

assert (config == "mumble" || config == "murmur");

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

  nativeBuildInputs = optionals (config == "mumble")[
    python
    qt4
    qt5
  ];

  buildInputs = [
    avahi
    boost
    openssl
    protobuf-cpp
    qt4
    qt5
  ] ++ optionals (config == "mumble") [
    alsa-lib
    jack2_lib
    libsndfile
    mesa_noglu
    opus
    portaudio
    pulseaudio_lib
    speechd
    speex
    xorg.fixesproto
    xorg.inputproto
    xorg.libX11
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.xproto
  ] ++ optionals (config == "murmur") [
    ice
    libcap
  ];

  patches = optionals (jack2_lib != null) [
    ./mumble-jack-support.patch
  ];

  postPatch = optionalString (config == "mumble") ''
    export MUMBLE_PYTHON="${python}/bin/python"
  '' + optionalString (config == "murmur" && ice != null) ''
    grep -Rl '/usr/share/Ice' . | \
      xargs sed -i 's,/usr/share/Ice/,${ice}/,g'
  '';

  configureFlags = [
    "CONFIG+=${boolNo (config == "mumble")}client"
    "CONFIG+=${boolNo (config == "murmur")}server"
    "CONFIG+=shared"
    "CONFIG+=no-static"
    "CONFIG+=no-g15"
    "CONFIG+=dbus"
    "CONFIG+=${boolNo (avahi != null)}bonjour"
    "CONFIG+=embed-tango-icons"
    # static_qt_plugins
    "CONFIG+=no-static_qt_plugins"
    "CONFIG+=packaged"
    "CONFIG+=no-update"
    "CONFIG+=no-embed-qt-translations"
    "CONFIG+=${boolNo (speechd != null)}speechd"
  ] ++ optionals (config == "mumble") [
    "CONFIG+=${boolNo (alsa-lib != null)}alsa"
    "CONFIG+=no-directsound"
    "CONFIG+=${boolNo (jack2_lib != null)}jackaudio"
    "CONFIG+=no-oss"
    "CONFIG+=${boolNo (portaudio != null)}portaudio"
    "CONFIG+=no-wasapi"
    # TODO: asio support, ASIOInput.h
    "CONFIG+=no-asio"
    "CONFIG+=no-bundled-speex"
    # sbcelt
    "CONFIG+=bundled-celt"
    "CONFIG+=${boolNo (opus != null)}opus"
    "CONFIG+=no-bundled-opus"
    "CONFIG+=vorbis-recording"
    "CONFIG+=${boolNo mumbleOverlay}overlay"
    "CONFIG+=${boolNo (qt5 != null)}qt4-legacy-compat"
  ] ++ optionals (config == "murmur") [
    "CONFIG+=${boolNo (ice != null)}ice"
    # TODO: grpc support, protoc-gen-grpc not found
    "CONFIG+=no-grpc"
    "CONFIG+=qssldiffiehellmanparameters"
  ];

  configurePhase = ''
    qmake $configureFlags DEFINES+="PLUGIN_PATH=$out/lib"
  '';

  makeFlags = [
    "release"
  ];

  installPhase = ''
    mkdir -pv "$out"/{lib,bin}
    find release -type f -not -name \*.\* -exec cp -v {} $out/bin \;
    find release -type f -name \*.\* -exec cp -v {} $out/lib \;

    mkdir -pv $out/share/man/man1
    cp -v man/mum* $out/share/man/man1
  '' + optionalString (config == "mumble") ''
    install -D -m755 -v 'scripts/mumble-overlay' "$out/bin/mumble-overlay"
    sed -i "$out/bin/mumble-overlay" \
      -e "s,/usr/lib,$out/lib,g"

    install -D -m644 -v 'scripts/mumble.desktop' \
      "$out/share/applications/mumble.desktop"

    mkdir -p $out/share/icons/hicolor/scalable/apps
    install -D -m644 -v 'icons/mumble.svg' "$out/share/icons/mumble.svg"
    ln -sv \
      "$out/share/icon/mumble.svg" \
      "$out/share/icons/hicolor/scalable/apps"
  '';

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
