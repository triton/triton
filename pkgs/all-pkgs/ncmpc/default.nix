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
, lyricsScreen ? true
  , pandoc
  , python
  , pythonPackages
  , ruby
  , wget
, outputsScreen ? false
, chatScreen ? false
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals
    optionalString;
};

let
  ncmpc-lyrics-plugins = stdenv.mkDerivation rec {
    name = "ncmpc-lyrics-plugins-${version}";
    version = "3";

    src = fetchurl {
      url = "https://github.com/codyopel/ncmpc-lyrics-plugins/archive/" +
            "v${version}.tar.gz";
      sha256 = "0cn1c2x6db06ajsrvp83r7s1a8x03a4ks6ws6j0kz8qcx0g15p7b";
    };

    buildInputs = [
      pandoc
      python
      ruby
    ];

    propagatedBuildInputs = [
      pythonPackages.requests2
    ];

    installPhase = ''
      for p in ./* ; do
        sed -i $p -e 's|"pandoc"|"${pandoc}/bin/pandoc"|'
        install -vD -m 755 "$p" "$out/bin/$(basename "$p")"
      done

    '';

    meta = with stdenv.lib; {
      description = "Meta package of ncmpc lyrics plugins";
      homepage = https://github.com/codyopel/ncmpc-lyrics-plugins;
      license = licenses.gpl2Plus;
      maintainers = with maintainers; [
        codyopel
      ];
      platforms = [
        "i686-linux"
        "x86_64-linux"
      ];
    };
  };
in

stdenv.mkDerivation rec {
  version = "0.24";
  name = "ncmpc-${version}";

  src = fetchurl {
    url = "http://www.musicpd.org/download/ncmpc/0/ncmpc-${version}.tar.xz";
    sha256 = "1sf3nirs3mcx0r5i7acm9bsvzqzlh730m0yjg6jcyj8ln6r7cvqf";
  };

  patches = [
  	# default ax_with_curses.m4 produces automagic dependency on ncursesw
  	# also, ncursesw is required for colors, so we force it here
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "ncmpc/ncmpc-0.24-ncursesw.patch";
      sha256 = "946aa473365b57533b4ba1ca908b1bea9684a529193b5c402ad8701d5713a2d3";
    })
  ];

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

  preConfigure =
    /* Re-run autoreconf after patching */ ''
    ./autogen.sh
  '' + optionalString (lirc != null)
    /* upstream lirc doesn't have a pkg-config file */ ''
    export LIBLIRCCLIENT_CFLAGS="-I${lirc}/include/lirc"
    export LIBLIRCCLIENT_LIBS="-llirc_client"
  '';

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

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Curses-based interface for MPD (music player daemon)";
    homepage = http://www.musicpd.org/clients/ncmpc/;
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
