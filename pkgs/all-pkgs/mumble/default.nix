{ stdenv
, fetchurl
, fetchgit

, alsa-lib
, avahi
, boost
, libcap
, libopus
, libsndfile
, mesa_noglu
, qt4
, qt5
, openssl
, protobuf
, speex
, xorg

, iceSupport ? true, zeroc_ice
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
      qt5.qtbase
    ];

    buildInputs = (overrides.buildInputs or [ ]) ++ [
      avahi
      boost
      openssl
      protobuf
    ] ++ optionals (source.qtVersion == 4) [
      qt4
    ] ++ optionals (source.qtVersion == 5) [
      qt5.qtbase
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

    nativeBuildInputs = optionals (source.qtVersion == 5) [
      qt5.qttools
    ];

    buildInputs = [
      alsa-lib
      libopus
      libsndfile
      mesa_noglu
      speex
      xorg.inputproto
      xorg.libX11
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
    ] ++ optionals (source.qtVersion == 5) [
      qt5.qtsvg
    ] ++ optionals jackSupport [
      jack2_lib
    ] ++ optionals speechdSupport [
      speechd
    ] ++ optionals pulseSupport [
      pulseaudio_lib
    ];

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
      grep -Rl '/usr/share/Ice' . | xargs sed -i 's,/usr/share/Ice/,${zeroc_ice}/,g'
    '';

    configureFlags = [
      "CONFIG+=no-client"
    ];

    buildInputs = [
      libcap
    ] ++ optionals iceSupport [
      zeroc_ice
    ];
  };

  stableSource = rec {
    version = "1.2.15";
    qtVersion = 4;

    src = fetchurl {
      url = "https://github.com/mumble-voip/mumble/releases/download/${version}/mumble-${version}.tar.gz";
      sha256 = "1yjywzybgq23ry5s2yihggs13ffrphhwl6rlp6lq79rkwvafa9v5";
    };
  };

  gitSource = rec {
    version = "1.3.0-git-2016-02-25";
    qtVersion = 5;

    src = fetchgit {
      url = "https://github.com/mumble-voip/mumble";
      rev = "93427affdeeafb0b4aebd79bafc30970d8f39584";
      sha256 = "1ssd6pxx5355jwvmc9m02jh0jiabyli0ql7xc8yh1z13c2zf79ji";
    };

    # TODO: Remove fetchgit as it requires git
    /*src = fetchFromGitHub {
      owner = "mumble-voip";
      repo = "mumble";
      rev = "13e494c60beb20748eeb8be126b27e1226d168c8";
      sha256 = "024my6wzahq16w7fjwrbksgnq98z4jjbdyy615kfyd9yk2qnpl80";
    };

    theme = fetchFromGitHub {
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
