{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, lib
, makeWrapper
, meson
, ninja

, glib
, ncurses
, libmpdclient
, lirc

, helpScreen ? false
, artistScreen ? true
, searchScreen ? true
, songScreen ? true
, keyScreen ? false
, lyricsScreen ? false
  #, pandoc
  , python
  , pythonPackages
  , ruby
  , wget
, outputsScreen ? false
, chatScreen ? false
}:

let
  inherit (lib)
    boolEn
    optionals
    optionalString;

  ncmpc-lyrics-plugins = stdenv.mkDerivation rec {
    name = "ncmpc-lyrics-plugins-${version}";
    version = "3";

    src = fetchurl {
      url = "https://github.com/codyopel/ncmpc-lyrics-plugins/archive/"
        + "v${version}.tar.gz";
      sha256 = "0cn1c2x6db06ajsrvp83r7s1a8x03a4ks6ws6j0kz8qcx0g15p7b";
    };

    buildInputs = [
      #pandoc
      python
      ruby
    ];

    propagatedBuildInputs = [
      pythonPackages.requests2
    ];

    /*installPhase = ''
      for p in ./* ; do
        sed -i $p -e 's|"pandoc"|"${pandoc}/bin/pandoc"|'
        install -vD -m 755 "$p" "$out/bin/$(basename "$p")"
      done

    '';*/

    meta = with lib; {
      description = "Meta package of ncmpc lyrics plugins";
      homepage = https://github.com/codyopel/ncmpc-lyrics-plugins;
      license = licenses.gpl2Plus;
      maintainers = with maintainers; [
        codyopel
      ];
      platforms = with platforms;
        x86_64-linux;
    };
  };
in
stdenv.mkDerivation rec {
  name = "ncmpc-0.30";

  src = fetchurl {
    url = "https://www.musicpd.org/download/ncmpc/0/${name}.tar.xz";
    hashOutput = false;
    sha256 = "e3fe0cb58b8a77f63fb1645c2f974b334f1614efdc834ec698ee7d861f1b12a3";
  };

  nativeBuildInputs = [
    gettext
    makeWrapper
    meson
    ninja
  ];

  buildInputs = [
    glib
    ncurses
    libmpdclient
    lirc
  ] ++ optionals lyricsScreen [
    ncmpc-lyrics-plugins
  ];

  preConfigure = optionalString (lirc != null)
    /* upstream lirc doesn't have a pkg-config file */ ''
    export LIBLIRCCLIENT_CFLAGS="-I${lirc}/include/lirc"
    export LIBLIRCCLIENT_LIBS="-llirc_client"
  '';

  configureFlags = [
    "--disable-mini"
    "--enable-multibyte"
    "--enable-locale"
    "--enable-nls"
    "--enable-colors"
    "--${boolEn (lirc != null)}-lirc"
    "--${boolEn helpScreen}-help-screen"
    "--enable-mouse"
    "--${boolEn artistScreen}-artist-screen"
    "--${boolEn searchScreen}-search-screen"
    "--${boolEn songScreen}-song-screen"
    "--${boolEn keyScreen}-key-screen"
    "--${boolEn lyricsScreen}-lyrics-screen"
    "--${boolEn outputsScreen}-outputs-screen"
    "--${boolEn chatScreen}-chat-screen"
    "--disable-werror"
    "--disable-debug"
    "--disable-test"
    "--disable-documentation"
  ];

  postInstall = optionalString lyricsScreen ''
    rm -fv $out/lib/ncmpc/lyrics/*
    mkdir -pv $out/lib/ncmpc/lyrics
    for i in ${ncmpc-lyrics-plugins}/bin/* ; do
      if [[ -f "$i" ]] ; then
        ln -sv $i $out/lib/ncmpc/lyrics/$(basename $i)
      fi
    done
  '';

  preFixup = optionalString lyricsScreen ''
    wrapProgram $out/bin/ncmpc \
      --prefix PYTHONPATH : "$PYTHONPATH"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "0392 335A 7808 3894 A430  1C43 236E 8A58 C6DB 4512";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Curses-based interface for MPD (music player daemon)";
    homepage = http://www.musicpd.org/clients/ncmpc/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
