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
, xz
, zlib

, channel

, pydebug ? false

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

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    concatStringsSep
    head
    optionals
    optionalString
    splitString
    versionAtLeast
    versionOlder
    wtFlag;

  source = (import ./sources.nix)."${channel}";

  isPy2 = versionOlder channel "3.0";
  isPy3 = versionAtLeast channel "3.0";
  ifPy2 = a: b:
    if isPy2 then
      a
    else
      b;
  ifPy3 = a: b:
    if isPy3 then
      a
    else
      b;

  # For alpha/beta releases we need to discard a<int> from the version
  # for part of the url.
  baseVersionPatch =
    if head (splitString "a" source.versionPatch) != source.versionPatch then
      head (splitString "a" source.versionPatch)
    else if head (splitString "b" source.versionPatch) != source.versionPatch then
      head (splitString "b" source.versionPatch)
    else if head (splitString "rc" source.versionPatch) != source.versionPatch then
      head (splitString "rc" source.versionPatch)
    else
      source.versionPatch;

  version = "${channel}.${source.versionPatch}";
in

stdenv.mkDerivation rec {
  name = "python-${version}";

  src = fetchurl {
    url = "https://www.python.org/ftp/python/${channel}.${baseVersionPatch}/"
      + "Python-${version}.tar.xz";
    inherit (source) sha256;
    hashOutput = false;
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
  ] ++ optionals isPy3 [
    xz
  ];

  setupHook = stdenv.mkDerivation {
    name = "python-${channel}-setup-hook";
    buildCommand = ''
      sed 's,@VERSION_MAJOR@,${channel},g' ${./setup-hook.sh.in} > $out
    '';
    preferLocalBuild = true;
  };

  patches = optionals isPy2 [
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
      sed -i setup.py \
        -e "s,$i,/no-such-path,g"
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
    (ifPy3 "--enable-loadable-sqlite-extensions" null)
    "--enable-ipv6"
    (ifPy2 "--enable-unicode=ucs4" null)
    #(wtFlag "gcc" (!stdenv.cc.isClang) null)
    #"--enable-big-digits" # py3
    (wtFlag "pydebug" pydebug null)
    #"--with-hash-algorithm" # py3
    (if (versionAtLeast channel "3.5") then
      # Flag is not a boolean
      (if stdenv.cc.isClang then
        "--with-address-sanitizer"
       else
         null)
     else
       null)
    "--with-system-expat"
    "--with-system-ffi"
    #"--with-system-libmpdec" # py3
    #"--with-dbmliborder"
    #"--with-signal-module"
    "--with-threads"
    #"--with-doc-strings"
    #"--with-tsc"
    #"--with-pymalloc"
    "--without-valgrind"
    #"--with-fpectl"
    #"--with-libm"
    #"--with-libc"
    #"--with-computed-gotos"
    #"--with-ensurepip"
  ];

  postInstall =
    /* Needed for some packages, especially packages that
       backport functionality to 2.x from 3.x */ ''
    for item in $out/lib/python${channel}/test/* ; do
      if [[ "$item" != */test_support.py* ]] ; then
        rm -rvf "$item"
      else
        echo $item
      fi
    done
  '' + optionalString isPy3
    /* Fixes impurities but drastically slows down built-in pip
       TODO: Find a better solution */ ''
    grep -r --include '*.pyc' -l "$NIX_BUILD_TOP" "$out" | xargs rm
  '' + optionalString isPy3 ''
    pushd $out/lib/pkgconfig
      if [ ! -f 'python3.pc' ] ; then
        ln -sv python-*.pc python3.pc
      fi
    popd
  '' + ''
    touch $out/lib/python${channel}/test/__init__.py
  '' + ''
    paxmark E $out/bin/python${channel}
  '' + optionalString isPy3
    /* Some programs look for libpython<major>.<minor>.so */ ''
    if [ ! -f "$out/lib/libpython${channel}.so" ] ; then
      ln -sv \
        $out/lib/libpython3.so \
        $out/lib/libpython${channel}.so
    fi
  '' + optionalString isPy3
    /* Symlink include directory */ ''
    if [ ! -d "$out/include/python${channel}" ] ; then
      ln -sv \
        $out/include/python${channel}m \
        $out/include/python${channel}
    fi
  '' + optionalString isPy2 ''
    # TODO: reference reason for pdb symlink
    ln -sv $out/lib/python${channel}/pdb.py $out/bin/pdb
    ln -sv $out/lib/python${channel}/pdb.py $out/bin/pdb${channel}
    ln -sv $out/share/man/man1/{python2.7.1.gz,python.1.gz}
  '';

  preFixup = /* Simple test to make sure modules built */ ''
    echo "Testing modules"
    $out/bin/python${channel} -c "import bz2"
    $out/bin/python${channel} -c "import crypt"
    $out/bin/python${channel} -c "import ctypes"
    $out/bin/python${channel} -c "import curses"
    $out/bin/python${channel} -c "from curses import panel"
    $out/bin/python${channel} -c "import math"
    $out/bin/python${channel} -c "import readline"
    $out/bin/python${channel} -c "import sqlite3"
    $out/bin/python${channel} -c "import ssl"
    $out/bin/python${channel} -c "import zlib"
  '' + optionalString isPy2 ''
    $out/bin/python${channel} -c "import gdbm"
  '' + optionalString isPy3 ''
    $out/bin/python${channel} -c "from dbm import gnu"
    $out/bin/python${channel} -c "import lzma"
  '';

  postFixup =
    let
      ifPyDebug =
        if pydebug then
          "d"
        else
          "";
      # e.g. _sysconfigdata_m_linux_x86_64-linux-gnu
      sysconfigdata =
        if versionAtLeast channel "3.6" then
          "_sysconfigdata_m_linux_${targetSystem}-gnu"
        else
          "_sysconfigdata";
      sysconfigdatapy = "${sysconfigdata}.py";
      configdir =
        if versionOlder channel "3.0" then
          "config"
        else if versionAtLeast channel "3.6" then
          # FIXME: implement a list of platform tuples instead of
          #        using the targetSystem string.  We may eventually
          #        add a non-GNU system and our tuples differ
          #        from those returned by the autoconf macro.
          "config-${channel}${ifPyDebug}m-${targetSystem}-gnu"
        else
          "config-${channel}${ifPyDebug}m";
    in ''
      # The lines we are replacing dont include libpython so we parse it out
      LIBS_WITH_PYTHON="$(pkg-config --libs --static $out/lib/pkgconfig/python-${channel}.pc)"
      LIBS="$(echo "$LIBS_WITH_PYTHON" | sed 's,[ ]*\(-L\|-l\)[^ ]*python[^ ]*[ ]*, ,g')"
    '' + ''
      sed -i $out/lib/python${channel}/${configdir}/Makefile \
        -e "s@^LIBS=.*@LIBS= $LIBS@g" \
        -e "s@$NIX_BUILD_TOP@/no-such-path@g"

      # We need to update _sysconfigdata.py{,o,c}
      sed -i $out/lib/python${channel}/${sysconfigdatapy} \
        -e "s@'\(SH\|\)LIBS': '.*',@'\1LIBS': '$LIBS',@g" \
        -e "s@$NIX_BUILD_TOP@/no-such-path@g"
    '' + optionalString isPy2 ''
      rm $out/lib/python${channel}/${sysconfigdatapy}{o,c}
    '' + optionalString isPy3 ''
      rm $out/lib/python${channel}/__pycache__/_sysconfigdata*.pyc
    '' + /* FIXME: the platform triplet included in the module name
                   currently includes invalid characters (-). */
      optionalString (versionOlder channel "3.6") ''
      $out/bin/python${channel} -c "import ${sysconfigdata}"
      $out/bin/python${channel} -O -c "import ${sysconfigdata}"
      $out/bin/python${channel} -OO -c "import ${sysconfigdata}"
      $out/bin/python${channel} -OOO -c "import ${sysconfigdata}"

      sed --follow-symlinks -i $out/bin/python${channel}-config \
        -e "s@^LIBS=\".*\"@LIBS=\"$LIBS_WITH_PYTHON\"@g"
    '';

  # Used by python-2.7-deterministic-build.patch
  DETERMINISTIC_BUILD = 1;

  passthru = rec {
    inherit
      isPy2
      isPy3
      version
      channel;

    dbSupport = db != null;
    opensslSupport = openssl != null;
    readlineSupport = readline != null;
    sqliteSupport = sqlite != null;
    tkSupport = false;
    zlibSupport = zlib != null;

    libPrefix = "python${channel}";
    executable = "python${channel}";
    buildEnv = callPackage ../wrapper.nix { python = self; };
    sitePackages = "lib/${libPrefix}/site-packages";
    interpreter = "${self}/bin/${executable}";

    srcVerification = fetchurl rec {
      inherit (source) pgpKeyFingerprint;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
    };
  };

  meta = with stdenv.lib; {
    description = "An interpreted, object-oriented programming language";
    homepage = "http://www.python.org/";
    license = licenses.psf-2;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
