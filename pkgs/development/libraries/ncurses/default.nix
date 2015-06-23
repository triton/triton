{ stdenv, fetchurl, pkgconfig, libtool

# Optional Dependencies
, gpm ? null

# Extra Options
, abiVersion ? "5"
, unicode ? true
, threaded ? false # This breaks a lot of libraries because it enables the opaque includes
}:

with stdenv.lib;
let
  optGpm = stdenv.shouldUsePkg gpm;
in
stdenv.mkDerivation rec {
  name = "ncurses-5.9";

  src = fetchurl {
    url = "mirror://gnu/ncurses/${name}.tar.gz";
    sha256 = "0fsn7xis81za62afan0vvm38bvgzg5wfmv1m86flqcj0nj7jjilh";
  };

  # gcc-5.patch should be removed after 5.9
  patches = [ ./clang.patch ./gcc-5.patch ];

  nativeBuildInputs = [ pkgconfig libtool ];
  buildInputs = [ optGpm ];

  configureFlags = [
    (mkOther              "includedir"     "\${out}/include")
    (mkWith   true        "abi-version"    abiVersion)
    (mkWith   true        "cxx"            null)
    (mkWith   true        "cxx-binding"    null)
    (mkWith   false       "ada"            null)
    (mkWith   true        "manpages"       null)
    (mkWith   true        "progs"          null)
    (mkWith   doCheck     "tests"          null)
    (mkWith   true        "curses-h"       null)
    (mkEnable true        "pc-files"       null)
    (mkEnable true        "mixed-case"     "auto")
    (mkWith   true        "libtool"        null)
    (mkWith   true        "shared"         null)
    (mkWith   true        "normal"         null)
    (mkWith   false       "debug"          null)
    (mkWith   false       "profile"        null)
    (mkWith   false       "termlib"        null)
    (mkWith   false       "ticlib"         null)
    (mkWith   optGpm      "gpm"            null)
    (mkWith   true        "dlsym"          null)
    (mkWith   true        "sysmouse"       "maybe")
    (mkEnable true        "relink"         null)
    (mkEnable true        "overwrite"      null)
    (mkEnable true        "database"       null)
    (mkWith   false       "hashed-db"      null)
    (mkWith   true        "fallbacks"      "")
    (mkWith   true        "xterm-new"      null)
    # With terminfo-dirs
    # With default-terminfo-dir
    # Enable big-core: Autodetected
    # Enable big-strings: Autodetected
    (mkEnable false       "termcap"        null)
    (mkWith   true        "termpath"       "\${out}/share/misc/termcap")
    (mkEnable true        "getcap"         null)
    (mkEnable false       "getcap-cache"   null)
    (mkEnable true        "home-terminfo"  null)
    (mkEnable true        "root-environ"   null)
    (mkEnable true        "symlinks"       null)
    (mkEnable false       "broken-linker"  null)
    (mkEnable false       "bsdpad"         null)
    (mkEnable unicode     "widec"          null)
    (mkEnable true        "lp64"           null)
    (mkEnable true        "tparm-varargs"  null)
    (mkWith   true        "tic-depends"    null)
    (mkWith   true        "bool"           null)
    # With caps
    # With chtype
    # With ospeed
    # With mmask-t
    # With ccharw-max
    (mkWith   false       "rcs-ids"        null)
    (mkEnable true        "ext-funcs"      null)
    (mkEnable true        "sp-funcs"       null)
    (mkEnable false       "term-driver"    null)  # Breaks htop
    (mkEnable true        "const"          null)
    (mkEnable true        "ext-colors"     null)
    (mkEnable true        "ext-mouse"      null)
    (mkEnable true        "no-padding"     null)
    (mkEnable false       "signed-char"    null)
    (mkEnable true        "sigwinch"       null)
    (mkEnable true        "tcap-names"     null)
    (mkWith   true        "devlop"         null)
    (mkEnable true        "hard-tabs"      null)
    (mkEnable true        "xmc-glitch"     null)
    (mkWith   true        "assumed-color"  null)
    (mkEnable true        "hashmap"        null)
    (mkEnable true        "colorfgbg"      null)
    (mkEnable true        "interop"        null)
    (mkWith   false       "pthread"        null)
    (mkEnable false       "pthreads-eintr" null)
    (mkEnable false       "weak-symbols"   null)
    (mkEnable threaded    "reentrant"      null)
    # With wrap-prefix
    (mkEnable true        "safe-sprintf"   null)
    (mkEnable true        "scroll-hints"   null)
    (mkEnable false       "wgetch-events"  null)
    (mkEnable true        "echo"           null)
    (mkEnable true        "warnings"       null)
    (mkEnable false       "assertions"     null)
    (mkEnable false       "expanded"       null)
    (mkEnable true        "macros"         null)
    (mkWith   false       "trace"          null)
  ];

  preConfigure = ''
    export PKG_CONFIG_LIBDIR="$out/lib/pkgconfig"
    mkdir -p "$PKG_CONFIG_LIBDIR"
  '' + stdenv.lib.optionalString stdenv.isCygwin ''
    sed -i -e 's,LIB_SUFFIX="t,LIB_SUFFIX=",' configure
  '';

  NIX_LDFLAGS = if threaded then "-lpthread" else null;

  selfNativeBuildInput = true;

  enableParallelBuilding = true;

  doCheck = false;

  # When building a wide-character (Unicode) build, create backward
  # compatibility links from the the "normal" libraries to the
  # wide-character libraries (e.g. libncurses.so to libncursesw.so).
  postInstall = ''
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
            ln -svf lib''${lib}$suffix.$dylibtype.${abiVersion} $out/lib/lib$lib$newsuffix.$dylibtype.${abiVersion}
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
  '' + optionalString threaded ''
    # Fix .la files to include pthreads
    find $out/lib -name \*.la -type f | xargs sed -i "s,\(dependency_libs='\),\1 -lpthread,"
  '';

  meta = {
    description = "Free software emulation of curses in SVR4 and more";

    longDescription = ''
      The Ncurses (new curses) library is a free software emulation of
      curses in System V Release 4.0, and more.  It uses Terminfo
      format, supports pads and color and multiple highlights and
      forms characters and function-key mapping, and has all the other
      SYSV-curses enhancements over BSD Curses.

      The ncurses code was developed under GNU/Linux.  It has been in
      use for some time with OpenBSD as the system curses library, and
      on FreeBSD and NetBSD as an external package.  It should port
      easily to any ANSI/POSIX-conforming UNIX.  It has even been
      ported to OS/2 Warp!
    '';

    homepage = http://www.gnu.org/software/ncurses/;

    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ wkennington ];
  };

  passthru = {
    ldflags = "-lncurses";
    inherit unicode abiVersion;
  };
}
