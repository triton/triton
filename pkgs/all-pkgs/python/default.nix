{ stdenv
, fetchurl

, bzip2
, db
, expat
, gdbm
, libffi
, lzma
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
 * look for or link against libpython:
 * - gst-python 0.10.x & 1.x
 * - libtorrent-rasterbar
 * - pycairo
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
assert isPy3;

stdenv.mkDerivation rec {
  name = "python-${version}";
  inherit versionMajor;
  inherit versionMinor;
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz";
    inherit sha256;
  };

  setupHook = stdenv.mkDerivation {
    name = "python-${versionMajor}-setup-hook";
    buildCommand = ''
      sed 's,@VERSION_MAJOR@,${versionMajor},g' ${./setup-hook.sh.in} > $out
    '';
    preferLocalBuild = true;
  };

  postPatch =
    /* Prevent setup.py from looking for include/lib
       directories in impure paths */ ''
    for i in /usr /sw /opt /pkg ; do
      substituteInPlace ./setup.py \
        --replace $i /no-such-path
    done
  '';

  configureFlags = [
    "--disable-universalsdk"
    "--disable-framework"
    "--enable-shared"
    #"--disable-profiling"
    "--disable-toolbox-glue"
    "--enable-loadable-sqlite-extensions"
    "--enable-ipv6"
    #"--enable-big-digits"
    #(wtFlag "gcc" (!stdenv.cc.isClang) null)
    #"--with-hash-algorithm"
    # Flag is not a boolean
    (verFlag (versionAtLeast versionMajor "3.5")
      (if stdenv.cc.isClang then
        "--with-address-sanitizer"
       else
         null))
    "--with-system-expat"
    "--with-system-ffi"
    #"--with-system-libmpdec"
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
  NIX_LDFLAGS = optionalString isLinux "-lgcc_s";

  preConfigure = ''
    configureFlagsArray+=(
      CPPFLAGS="${concatStringsSep " " (map (p: "-I${p}/include") buildInputs)}"
      LDFLAGS="${concatStringsSep " " (map (p: "-L${p}/lib") buildInputs)}"
      LIBS="-lncurses"
    )
  '';

  buildInputs = [
    bzip2
    db
    expat
    gdbm
    libffi
    lzma
    ncurses
    openssl
    readline
    sqlite
    stdenv.cc.libc
    zlib
  ];

  postInstall =
    /* Needed for some packages, especially packages that
       backport functionality to 2.x from 3.x */ ''
    # needed for some packages, especially packages that backport functionality
    # to 2.x from 3.x
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
  '' +
    /* Some programs look for libpython<major>.<minor>.so */ ''
    if [[ ! -f "$out/lib/libpython${versionMajor}.so" ]] ; then
      ln -sv \
        $out/lib/libpython3.so \
        $out/lib/libpython${versionMajor}.so
    fi
  '' +
    /* Symlink include directory */ ''
    if [[ ! -d "$out/include/python${versionMajor}" ]] ; then
      ln -sv \
        $out/include/python${versionMajor}m \
        $out/include/python${versionMajor}
    fi
  '';

  # TODO: move tests to checkPhase
  preFixup = ''
    echo "Testing modules"
    $out/bin/python${versionMajor} -c "import bz2"
    $out/bin/python${versionMajor} -c "import crypt"
    $out/bin/python${versionMajor} -c "import ctypes"
    $out/bin/python${versionMajor} -c "import curses"
    $out/bin/python${versionMajor} -c "from curses import panel"
    $out/bin/python${versionMajor} -c "from dbm import gnu"
    $out/bin/python${versionMajor} -c "import lzma"
    $out/bin/python${versionMajor} -c "import math"
    $out/bin/python${versionMajor} -c "import readline"
    $out/bin/python${versionMajor} -c "import sqlite3"
    $out/bin/python${versionMajor} -c "import ssl"
    $out/bin/python${versionMajor} -c "import zlib"
  '';

  enableParallelBuilding = true;

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
    isPy2 = false;
    isPy3 = true;
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
