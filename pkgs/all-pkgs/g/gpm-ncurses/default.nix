{ stdenv
, autoconf
, automake
, bison
, fetchurl
, flex
, libtool
, texinfo
}:

let
  ncursesName = "ncurses-6.0";
  gpmName = "gpm-1.20.7";
in

stdenv.mkDerivation {
  name = "${gpmName}+${ncursesName}";

  srcs = [
    (fetchurl {
      url = "mirror://gnu/ncurses/${ncursesName}.tar.gz";
      sha256 = "0q3jck7lna77z5r42f13c4xglc7azd19pxfrjrpgp2yf615w4lgm";
    })
    (fetchurl {
      url = "http://www.nico.schottelius.org/software/gpm/archives/${gpmName}.tar.bz2";
      multihash = "QmfXgn4nAx8eudgPcBMhRFtqy3LAybB1cdRJmgkGjsf8Mx";
      sha256 = "13d426a8h403ckpc8zyf7s2p5rql0lqbg2bv0454x0pvgbfbf4gh";
    })
  ];

  srcRoot = ".";

  nativeBuildInputs = [
    autoconf
    automake
    bison
    flex
    libtool
    texinfo
  ];

  # Prevent build directory impurities from being injected
  YACC = "bison -l -y";

  # Make sure we don't introduce SOURCE_DATE_EPOCH impurities
  postUnpack = ''
    mkdir src
    mv gpm* ncurses* src
    cd src
  '';

  installPhase = ''
    declare -A GPM_FILES
    declare -A NCURSES_FILES

    # Build the first round of gpm
    pushd gpm*
    ./autogen.sh
    configureFlagsGpm=(
      "--prefix=$out"
      "--disable-static"
      "--sysconfdir=/etc"
      "--localstatedir=/var"
    )
    ./configure "''${configureFlagsGpm[@]}" --without-curses
    make "SHELL=${stdenv.shell}" -j $NIX_BUILD_CORES
    make "SHELL=${stdenv.shell}" -j $NIX_BUILD_CORES install
    ln -sv libgpm.so.2 $out/lib/libgpm.so
    for file in $(find $out -type l -or -type f); do
      GPM_FILES["$file"]=1
    done
    popd

    # Build the first round of ncurses
    pushd ncurses*
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$out/include"
    export NIX_LDFLAGS="$NIX_LDFLAGS -L$out/lib"
    export PKG_CONFIG_LIBDIR="$out/lib/pkgconfig"
    mkdir -p "$PKG_CONFIG_LIBDIR"
    configureFlagsNcurses=(
      "--prefix=$out"
      "--includedir=$out/include"
      "--with-pkg-config-libdir=$PKG_CONFIG_LIBDIR"
      "--disable-static"
      "--without-ada"
      "--with-cxx"
      "--with-cxx-binding"
      "--enable-db-install"
      "--with-manpages"
      "--with-progs"
      "--without-tests"
      "--with-curses-h"
      "--enable-pc-files"
      # With pc-suffix
      "--enable-mixed-case=auto"
      # With install-prefix
      "--with-libtool"
      "--with-shared"
      "--with-normal"
      "--without-debug"
      "--without-profile"
      "--with-cxx-shared"
      "--without-termlib"
      "--without-ticlib"
      "--with-gpm"
      "--with-dlsym"
      "--with-sysmouse=maybe"
      "--enable-relink"
      # With extra-suffix
      "--enable-overwrite"
      "--enable-database"
      "--without-hashed-db"
      "--with-fallbacks="
      "--with-xterm-new"
      # With xterm-kbs
      # With terminfo-dirs
      # With default-terminfo-dir
      # Enable big-core: Autodetected
      # Enable big-strings: Autodetected
      "--disable-termcap"
      "--with-termpath=$out/share/misc/termcap"
      "--enable-getcap"
      "--disable-getcap-cache"
      "--enable-home-terminfo"
      "--enable-root-environ"
      "--enable-symlinks"
      "--disable-broken-linker"
      "--disable-bsdpad"
      "--enable-widec"
      "--enable-lp64"
      "--enable-tparm-varargs"
      "--with-tic-depends"
      "--with-bool"
      # With caps
      # With chtype
      # With ospeed
      # With mmask-t
      # With ccharw-max
      "--without-rcs-ids"
      "--enable-ext-funcs"
      "--enable-sp-funcs"
      "--disable-term-driver"  # Breaks htop
      "--enable-const"
      "--enable-ext-colors"
      "--enable-ext-mouse"
      "--enable-ext-putwin"
      "--enable-no-padding"
      "--disable-signed-char"
      "--enable-sigwinch"
      "--enable-tcap-names"
      "--with-devlop"
      "--enable-hard-tabs"
      "--enable-xmc-glitch"
      "--with-assumed-color"
      "--enable-hashmap"
      "--enable-colorfgbg"
      "--enable-interop"
      "--without-pthread"
      "--disable-pthreads-eintr"
      "--disable-weak-symbols"
      "--disable-reentrant"
      # With wrap-prefix
      "--enable-safe-sprintf"
      "--enable-scroll-hints"
      "--disable-wgetch-events"
      "--enable-echo"
      "--enable-warnings"
      "--disable-assertions"
      "--disable-expanded"
      "--enable-macros"
      "--without-trace"
    )
    ncursesBuild () {
      ./configure "''${configureFlagsNcurses[@]}"

      sed -i "s,^\(#define LIBGPM_SONAME\).*,\1 \"$out/lib/libgpm.so\",g" ncurses/base/lib_mouse.c

      make "SHELL=${stdenv.shell}" -j $NIX_BUILD_CORES
      for file in "''${!NCURSES_FILES[@]}"; do
        rm "$file"
      done
      make "SHELL=${stdenv.shell}" -j $NIX_BUILD_CORES install

      # Determine what suffixes our libraries have
      suffix="$(awk -F': ' 'f{print $3; f=0} /default library suffix/{f=1}' config.log)"
      libs="$(ls $out/lib/pkgconfig | tr ' ' '\n' | sed "s,\(.*\)$suffix\.pc,\1,g")"
      suffixes="$(echo "$suffix" | awk '{for (i=1; i < length($0); i++) {x=substr($0, i+1, length($0)-i); print x}}')"

      # Get the path to the config util
      cfg=$(basename $out/bin/ncurses*-config)

      # symlink the full suffixed include directory
      ln -svf . $out/include/ncurses$suffix

      for newsuffix in $suffixes ""; do
        # Create a non-abi versioned config util links
        ln -svf $cfg $out/bin/ncurses$newsuffix-config

        # Allow for end users who #include <ncurses?w/*.h>
        ln -svf . $out/include/ncurses$newsuffix

        for lib in $libs; do
          for dylibtype in so dll dylib; do
            if [ -e "$out/lib/lib''${lib}$suffix.$dylibtype" ]; then
              ln -svf lib''${lib}$suffix.$dylibtype $out/lib/lib$lib$newsuffix.$dylibtype
            fi
          done
          for statictype in a dll.a la; do
            if [ -e "$out/lib/lib''${lib}$suffix.$statictype" ]; then
              ln -svf lib''${lib}$suffix.$statictype $out/lib/lib$lib$newsuffix.$statictype
            fi
          done
          ln -svf ''${lib}$suffix.pc $out/lib/pkgconfig/$lib$newsuffix.pc
        done
      done

      # In the standard environment we don't want to have bootstrap references
      sed -i 's,${stdenv.shell},/bin/sh,g' $out/bin/*-config
    }
    ncursesBuild
    for file in $(find $out -type l -or -type f); do
      if [ "''${GPM_FILES["$file"]}" != "1" ]; then
        NCURSES_FILES["$file"]=1
      fi
    done
    popd

    # Build the final gpm
    pushd gpm*
    for file in "''${!GPM_FILES[@]}"; do
      rm "$file"
    done
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$out/include"
    export NIX_LDFLAGS="$NIX_LDFLAGS -L$out/lib"
    ./configure "''${configureFlagsGpm[@]}" --with-curses
    make "SHELL=${stdenv.shell}" -j $NIX_BUILD_CORES
    make "SHELL=${stdenv.shell}" -j $NIX_BUILD_CORES install
    ln -sv libgpm.so.2 $out/lib/libgpm.so
    popd

    # Build the final ncurses
    pushd ncurses*
    ncursesBuild
    popd
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
