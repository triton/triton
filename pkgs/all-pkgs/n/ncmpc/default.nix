{ stdenv
, autoconf
, autoconf-archive
, automake
, fetchTritonPatch
, fetchurl
, gettext
, makeWrapper
# Required
, glib
, ncurses
, libmpdclient
# Optional
, lirc
# Screens
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
  inherit (stdenv.lib)
    enFlag
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

    meta = with stdenv.lib; {
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
  name = "ncmpc-0.27";

  src = fetchurl {
    url = "https://www.musicpd.org/download/ncmpc/0/${name}.tar.xz";
    sha256 = "f9a26a3fc869cfdf0a16b0ea3e6512c2fe28a031bbc71b1d24a2bf0bbd3e15d9";
  };

  nativeBuildInputs = [
    autoconf
    autoconf-archive
    automake
    gettext
    makeWrapper
  ];

  buildInputs = [
    glib
    ncurses
    libmpdclient
    lirc
  ] ++ optionals lyricsScreen [
    ncmpc-lyrics-plugins
  ];

  patches = [
  	# default ax_with_curses.m4 produces automagic dependency on ncursesw
  	# also, ncursesw is required for colors, so we force it here
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "ncmpc/ncmpc-0.24-ncursesw.patch";
      sha256 = "946aa473365b57533b4ba1ca908b1bea9684a529193b5c402ad8701d5713a2d3";
    })
  ];

  preConfigure =
    /* Re-run autoreconf after patching */ ''
    ./autogen.sh
  '' + optionalString (lirc != null)
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
    (enFlag "lirc" (lirc != null) null)
    (enFlag "help-screen" helpScreen null)
    "--enable-mouse"
    (enFlag "artist-screen" artistScreen null)
    (enFlag "search-screen" searchScreen null)
    (enFlag "song-screen" songScreen null)
    (enFlag "key-screen" keyScreen null)
    (enFlag "lyrics-screen" lyricsScreen null)
    (enFlag "outputs-screen" outputsScreen null)
    (enFlag "chat-screen" chatScreen null)
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

  meta = with stdenv.lib; {
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
