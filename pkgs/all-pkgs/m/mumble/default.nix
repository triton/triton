{ stdenv
, fetchurl
, fetchgit
, python

, alsa-lib
, avahi
, boost
, libcap
, libsndfile
, mesa_noglu
, opus
, qt4
, qt5
, openssl
, protobuf-cpp
, speex
, xorg

, iceSupport ? true, ice
, jackSupport ? false, jack2_lib
, pulseSupport ? false, pulseaudio_lib
, speechdSupport ? false, speechd
}:

let
  inherit (stdenv.lib)
    optional
    optionals;

  generic = overrides: source: stdenv.mkDerivation (source // overrides // {
    name = "${overrides.type}-${source.version}";

    patches = optionals jackSupport [
      ./mumble-jack-support.patch
    ];

    nativeBuildInputs = (overrides.nativeBuildInputs or [ ])
      ++ optionals (source.qtVersion == 4) [
      qt4
    ] ++ optionals (source.qtVersion == 5) [
      qt5
    ];

    buildInputs = (overrides.buildInputs or [ ]) ++ [
      avahi
      boost
      openssl
      protobuf-cpp
    ] ++ optionals (source.qtVersion == 4) [
      qt4
    ] ++ optionals (source.qtVersion == 5) [
      qt5
    ];

    configureFlags = (overrides.configureFlags or [ ])
      ++ [
      "CONFIG+=shared"
      "CONFIG+=no-g15"
      "CONFIG+=packaged"
      "CONFIG+=no-update"
      "CONFIG+=no-embed-qt-translations"
      "CONFIG+=bundled-celt"
      "CONFIG+=no-bundled-opus"
      "CONFIG+=no-bundled-speex"
    ] ++ optionals (!speechdSupport) [
      "CONFIG+=no-speechd"
    ] ++ optionals jackSupport [
      "CONFIG+=no-oss"
      "CONFIG+=no-alsa"
      "CONFIG+=jackaudio"
    ];

    configurePhase = ''
      qmake $configureFlags DEFINES+="PLUGIN_PATH=$out/lib"
    '';

    makeFlags = [
      "release"
    ];

    installPhase = ''
      mkdir -p $out/{lib,bin}
      find release -type f -not -name \*.\* -exec cp {} $out/bin \;
      find release -type f -name \*.\* -exec cp {} $out/lib \;

      mkdir -p $out/share/man/man1
      cp man/mum* $out/share/man/man1
    '' + (overrides.installPhase or "");

    meta = with stdenv.lib; {
      description = "Low-latency, high quality voice chat software";
      homepage = "http://mumble.sourceforge.net/";
      license = licenses.bsd3;
      maintainers = with maintainers; [
        wkennington
      ];
      platforms = with platforms;
        x86_64-linux;
    };
  });

  client = source: generic {
    type = "mumble";

    nativeBuildInputs = [
      python
    ];

    buildInputs = [
      alsa-lib
      libsndfile
      mesa_noglu
      opus
      speex
      xorg.fixesproto
      xorg.inputproto
      xorg.libX11
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.xproto
    ] ++ optionals jackSupport [
      jack2_lib
    ] ++ optionals speechdSupport [
      speechd
    ] ++ optionals pulseSupport [
      pulseaudio_lib
    ];

    postPatch = ''
      export MUMBLE_PYTHON="$(type -tP python)"
    '';

    configureFlags = [
      "CONFIG+=no-server"
    ];

    installPhase = ''
      cp scripts/mumble-overlay $out/bin
      sed -i "s,/usr/lib,$out/lib,g" $out/bin/mumble-overlay

      mkdir -p $out/share/applications
      cp scripts/mumble.desktop $out/share/applications

      mkdir -p $out/share/icons{,/hicolor/scalable/apps}
      cp icons/mumble.svg $out/share/icons
      ln -s $out/share/icon/mumble.svg $out/share/icons/hicolor/scalable/apps
    '';
  } source;

  server = generic {
    type = "murmur";

    postPatch = optional iceSupport ''
      grep -Rl '/usr/share/Ice' . | xargs sed -i 's,/usr/share/Ice/,${ice}/,g'
    '';

    configureFlags = [
      "CONFIG+=no-client"
    ];

    buildInputs = [
      libcap
    ] ++ optionals iceSupport [
      ice
    ];
  };

  stableSource = rec {
    version = "1.2.16";
    qtVersion = 4;

    src = fetchurl {
      url = "https://github.com/mumble-voip/mumble/releases/download/${version}/mumble-${version}.tar.gz";
      sha256 = "ebd43860786f91a141e1347aa01379163f29530493bbc0186798c37faae37ac6";
    };
  };

  gitSource = rec {
    version = "1.3.0-git-2016-08-24";
    qtVersion = 5;

    src = fetchgit {
      url = "https://github.com/mumble-voip/mumble";
      rev = "355bf07c4389fc3088468039f939b47b5d1fd85c";
      sha256 = "1qy8ni2yvwzgfd6nw2zgqxqmm7wnsznr2pl36n5ww7rv75hszjgm";
    };

    # TODO: Remove fetchgit as it requires git
    /*src = fetchFromGitHub {
    version = 1;
      owner = "mumble-voip";
      repo = "mumble";
      rev = "13e494c60beb20748eeb8be126b27e1226d168c8";
      sha256 = "024my6wzahq16w7fjwrbksgnq98z4jjbdyy615kfyd9yk2qnpl80";
    };

    theme = fetchFromGitHub {
    version = 1;
      owner = "mumble-voip";
      repo = "mumble-theme";
      rev = "16b61d958f131ca85ab0f601d7331601b63d8f30";
      sha256 = "0rbh825mwlh38j6nv2sran2clkiwvzj430mhvkdvzli9ysjxgsl3";
    };

    prePatch = ''
      rmdir themes/Mumble
      ln -s ${theme} themes/Mumble
    '';*/
  };
in {
  mumble     = client stableSource;
  mumble_git = client gitSource;
  murmur     = server stableSource;
  murmur_git = server gitSource;
}
