{ stdenv
, autoconf
, automake
, bison
, fetchTritonPatch
, fetchurl
, flex
, libtool
}:

let
  inherit (stdenv.lib)
    concatMapStrings
    flip;

  ncursesName = "ncurses-6.1";
  gpmName = "gpm-1.20.7";

  gpmPatches = [
    (fetchTritonPatch {
      rev = "834722e09bb61b011744a53860e8a0238b919aa7";
      file = "g/gpm/glibc-2.26.patch";
      sha256 = "420820b560bfdb22e0e5fdc05416b380f179091b00c42c407add245ff317d32d";
    })
  ];
in
stdenv.mkDerivation {
  name = "${gpmName}+${ncursesName}";

  srcs = [
    (fetchurl {
      url = "mirror://gnu/ncurses/${ncursesName}.tar.gz";
      sha256 = "aa057eeeb4a14d470101eff4597d5833dcef5965331be3528c08d99cebaa0d17";
    })
    (fetchurl {
      url = "http://www.nico.schottelius.org/software/gpm/archives/${gpmName}.tar.bz2";
      multihash = "QmfXgn4nAx8eudgPcBMhRFtqy3LAybB1cdRJmgkGjsf8Mx";
      sha256 = "13d426a8h403ckpc8zyf7s2p5rql0lqbg2bv0454x0pvgbfbf4gh";
    })
  ];

  srcRoot = ".";

  nativeBuildInputs = [
    autoconf.bin
    automake.bin
    bison.bin
    flex.bin
    libtool.bin
  ];

  # Prevent build directory impurities from being injected
  YACC = "bison -l -y";

  # Make sure we don't introduce SOURCE_DATE_EPOCH impurities
  postUnpack = ''
    mkdir src
    mv gpm* ncurses* src
    cd src
  '';

  postPatch = flip concatMapStrings gpmPatches (p: ''
    patch -p1 -d gpm-* <${p}
  '') + ''
    sed -i '/SUBDIRS = /s, doc,,' gpm-*/Makefile.in
  '';

  installPhase = ''
    declare -A GPM_FILES
    declare -A NCURSES_FILES

    # Build the first round of gpm
    pushd gpm*
    ./autogen.sh
    configureFlagsGpm=(
      "--prefix=$dev"
      "--disable-static"
      "--sbindir=$lib/bin"
      "--sysconfdir=/etc"
      "--localstatedir=/var"
    )
    patchShebangs configure
    ./configure "''${configureFlagsGpm[@]}" --without-curses
    make "SHELL=${stdenv.shell}" -j $NIX_BUILD_CORES
    make "SHELL=${stdenv.shell}" -j $NIX_BUILD_CORES install
    ln -sv libgpm.so.2 $dev/lib/libgpm.so
    for file in $(find $dev -type l -or -type f); do
      GPM_FILES["$file"]=1
    done
    popd

    # Build the first round of ncurses
    pushd ncurses*
    patchShebangs configure
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$dev/include"
    export NIX_LDFLAGS="$NIX_LDFLAGS -L$dev/lib"
    export PKG_CONFIG_LIBDIR="$dev/lib/pkgconfig"
    mkdir -p "$PKG_CONFIG_LIBDIR"
    configureFlagsNcurses=(
      "--prefix=$dev"
      "--includedir=$dev/include"
      "--datadir=$lib/share"
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

      sed -i "s,^\(#define LIBGPM_SONAME\).*,\1 \"$lib/lib/libgpm.so\",g" ncurses/base/lib_mouse.c

      make "SHELL=${stdenv.shell}" -j $NIX_BUILD_CORES
      for file in "''${!NCURSES_FILES[@]}"; do
        rm "$file"
      done
      make "SHELL=${stdenv.shell}" -j $NIX_BUILD_CORES install

      # Determine what suffixes our libraries have
      suffix="$(awk -F': ' 'f{print $3; f=0} /default library suffix/{f=1}' config.log)"
      libs="$(ls $dev/lib/pkgconfig | tr ' ' '\n' | sed "s,\(.*\)$suffix\.pc,\1,g")"
      suffixes="$(echo "$suffix" | awk '{for (i=1; i < length($0); i++) {x=substr($0, i+1, length($0)-i); print x}}')"

      # Get the path to the config util
      cfg=$(basename $dev/bin/ncurses*-config)

      # symlink the full suffixed include directory
      ln -svf . $dev/include/ncurses$suffix

      for newsuffix in $suffixes ""; do
        # Create a non-abi versioned config util links
        ln -svf $cfg $dev/bin/ncurses$newsuffix-config

        # Allow for end users who #include <ncurses?w/*.h>
        ln -svf . $dev/include/ncurses$newsuffix

        local lib
        for lib in $libs; do
          for dylibtype in so dll dylib; do
            if [ -e "$dev/lib/lib''${lib}$suffix.$dylibtype" ]; then
              ln -svf lib''${lib}$suffix.$dylibtype $dev/lib/lib$lib$newsuffix.$dylibtype
            fi
          done
          for statictype in a dll.a la; do
            if [ -e "$dev/lib/lib''${lib}$suffix.$statictype" ]; then
              ln -svf lib''${lib}$suffix.$statictype $dev/lib/lib$lib$newsuffix.$statictype
            fi
          done
          ln -svf ''${lib}$suffix.pc $dev/lib/pkgconfig/$lib$newsuffix.pc
        done
      done
    }
    ncursesBuild
    for file in $(find $dev -type l -or -type f); do
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
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$dev/include"
    export NIX_LDFLAGS="$NIX_LDFLAGS -L$dev/lib"
    ./configure "''${configureFlagsGpm[@]}" --with-curses
    make "SHELL=${stdenv.shell}" -j $NIX_BUILD_CORES
    make "SHELL=${stdenv.shell}" -j $NIX_BUILD_CORES install
    ln -sv libgpm.so.2 $dev/lib/libgpm.so
    popd

    # Build the final ncurses
    pushd ncurses*
    ncursesBuild
    popd

    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"
    mkdir -p "$dev"/bin
    mv -v "$bin"/bin/*-config "$dev"/bin
    ln -sv "$lib"/bin/* "$bin"/bin

    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
