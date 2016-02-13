{ stdenv
, fetchTritonPatch
, fetchurl

, bzip2
, db
, expat
, gdbm
, libffi
, ncurses
, openssl
, readline
, sqlite
, zlib

# Inherit generics
, channel ? null

# Passthru
, callPackage
, self
}:

/*
 * Test the following packages when making major changes, as they
 *   look for or link against libpython:
 * - gst-python 0.10.x & 1.x
 * - libtorrent-rasterbar
 * - pycairo
 *
 * TODO:
 * - Fix dl module support (currently fails to build)
 * - Fix sqlite loadable extensions
 */

with {
  inherit (stdenv)
    isLinux;
  inherit (stdenv.lib)
    concatStringsSep
    optional
    optionals
    optionalString
    versionAtLeast
    versionOlder
    wtFlag;
  inherit (builtins.getAttr channel (import ./sources.nix))
    versionMinor
    sha256;
};

let
  versionMajor = channel;
  isPy2 = versionOlder versionMajor "3.0";
  isPy3 = versionAtLeast versionMajor "3.0";
  verFlag =
    ver:
    flag:
    if ver then
      flag
    else
      null;
in

assert channel != null;
assert isPy2;

stdenv.mkDerivation rec {
  name = "python-${version}";
  inherit versionMajor;
  inherit versionMinor;
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz";
    inherit sha256;
  };

  buildInputs = [
    bzip2
    db
    expat
    gdbm
    libffi
    ncurses
    openssl
    readline
    sqlite
    stdenv.cc.libc
    zlib
  ];

  setupHook = stdenv.mkDerivation {
    name = "python-${versionMajor}-setup-hook";
    buildCommand = ''
      sed 's,@VERSION_MAJOR@,${versionMajor},g' ${./setup-hook.sh.in} > $out
    '';
    preferLocalBuild = true;
  };

  patches = [
    # Patch python to put zero timestamp into pyc
    # if DETERMINISTIC_BUILD env var is set
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "python/python-2.7-deterministic-build.patch";
      sha256 = "7b8ed591008f8f0dafb7f2c95d06404501c84223197fe138df75791f12a9dc24";
    })
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "python/python-2.7-properly-detect-curses.patch";
      sha256 = "c0d17df5f1c920699f68a1c87973d626ea8423a4881927b0ac7a20f88ceedcb4";
    })
    # Python recompiles a Python if the mtime stored *in* the
    # pyc/pyo file differs from the mtime of the source file.  This
    # doesn't work in Nix because Nix changes the mtime of files in
    # the Nix store to 1.  So treat that as a special case.
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "python/python-2.x-nix-store-mtime.patch";
      sha256 = "0869ba7b51b1c4b8f9779118a75ce34332a69f41909e5dfcd9305d2a9bcce638";
    })
  ];

  postPatch =
    /* Prevent setup.py from looking for include/lib
       directories in impure paths */ ''
    for i in /usr /sw /opt /pkg ; do
      substituteInPlace ./setup.py \
        --replace $i /no-such-path
    done
  '';

  preConfigure =
    /* Something here makes portions of the build magically work,
       otherwise boost_python never builds */ ''
    configureFlagsArray+=(
      CPPFLAGS="${concatStringsSep " " (map (p: "-I${p}/include") buildInputs)}"
      LDFLAGS="${concatStringsSep " " (map (p: "-L${p}/lib") buildInputs)}"
      LIBS="-lncurses"
    )
  '';

  configureFlags = [
    "--disable-universalsdk"
    "--disable-framework"
    "--enable-shared"
    #"--disable-profiling"
    "--disable-toolbox-glue"
    "--enable-ipv6"
    "--enable-unicode=ucs4"
    #(wtFlag "gcc" (!stdenv.cc.isClang) null)
    "--with-system-expat"
    "--with-system-ffi"
    #"--with-dbmliborder"
    #"--with-signal-module"
    "--with-threads"
    #"--with-doc-strings"
    #"--with-tsc"
    #"--with-pymalloc"
    #"--without-valgrind"
    #"--with-fpectl"
    #"--with-libm"
    #"--with-libc"
    #"--with-computed-gotos"
    #"--with-ensurepip"
  ];

  # Should this be stdenv.cc.isGnu???
  NIX_LDFLAGS = "-lgcc_s";

  postInstall =
    /* Needed for some packages, especially packages that
       backport functionality to 2.x from 3.x */ ''
    for item in $out/lib/python${versionMajor}/test/* ; do
      if [[ "$item" != */test_support.py* ]]; then
        rm -rvf "$item"
      else
        echo $item
      fi
    done
  '' + ''
    touch $out/lib/python${versionMajor}/test/__init__.py
  '' + ''
    paxmark E $out/bin/python${versionMajor}
  '' + ''
    # TODO: reference reason for pdb symlink
    ln -sv $out/lib/python${versionMajor}/pdb.py $out/bin/pdb
    ln -sv $out/lib/python${versionMajor}/pdb.py $out/bin/pdb${versionMajor}
    ln -sv $out/share/man/man1/{python2.7.1.gz,python.1.gz}
  '';

  # TODO: move tests to checkPhase
  preFixup = ''
    echo "Testing modules"
    $out/bin/python${versionMajor} -c "import bz2"
    $out/bin/python${versionMajor} -c "import crypt"
    $out/bin/python${versionMajor} -c "import ctypes"
    $out/bin/python${versionMajor} -c "import curses"
    $out/bin/python${versionMajor} -c "from curses import panel"
    #$out/bin/python${versionMajor} -c "import dl"
    $out/bin/python${versionMajor} -c "import gdbm"
    $out/bin/python${versionMajor} -c "import math"
    $out/bin/python${versionMajor} -c "import readline"
    $out/bin/python${versionMajor} -c "import sqlite3"
    $out/bin/python${versionMajor} -c "import ssl"
    $out/bin/python${versionMajor} -c "import zlib"
  '';

  postFixup = ''
    # The lines we are replacing dont include libpython so we parse it out
    LIBS="$(pkg-config --libs --static python | sed 's,[ ]*\(-L\|-l\)[^ ]*python[^ ]*[ ]*, ,g')"

    sed -i "s@^LIBS=.*@LIBS= $LIBS@g" $out/lib/python*/config/Makefile

    # We need to update _sysconfigdata.py{,o,c}
    sed -i "s@'\(SH\|\)LIBS': '.*',@'\1LIBS': '$LIBS',@g" $out/lib/python*/_sysconfigdata.py
    rm $out/lib/python*/_sysconfigdata.py{o,c}
    $out/bin/python -c "import _sysconfigdata"
    $out/bin/python -O -c "import _sysconfigdata"

    sed --follow-symlinks -i "s@'-lpython'@'$out/lib', \0@g" $out/bin/python-config
  '';

  # Used by python-2.7-deterministic-build.patch
  DETERMINISTIC_BUILD = 1;

  passthru = rec {
    inherit
      version
      versionMajor;

    dbSupport = db != null;
    opensslSupport = openssl != null;
    readlineSupport = readline != null;
    sqliteSupport = sqlite != null;
    tkSupport = false;
    zlibSupport = zlib != null;

    libPrefix = "python${versionMajor}";
    executable = "python${versionMajor}";
    buildEnv = callPackage ../wrapper.nix { python = self; };
    isPy2 = true;
    isPy3 = false;
    sitePackages = "lib/${libPrefix}/site-packages";
    interpreter = "${self}/bin/${executable}";
  };

  meta = with stdenv.lib; {
    description = "An interpreted, object-oriented programming language";
    homepage = "http://www.python.org/";
    license = licenses.psf-2;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
