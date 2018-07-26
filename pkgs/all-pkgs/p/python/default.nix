{ stdenv
, fetchTritonPatch
, fetchurl
, lib

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
    boolWt
    concatStringsSep
    head
    optionals
    optionalString
    splitString
    versionAtLeast
    versionOlder;

  sources = {
    "2.7" = {
      versionPatch = "15";
      sha256 = "22d9b1ac5b26135ad2b8c2901a9413537e08749a753356ee913c84dbd2df5574";
      # Benjamin Peterson
      pgpKeyFingerprint = "C01E 1CAD 5EA2 C4F0 B8E3  5715 04C3 67C2 18AD D4FF";
    };
    "3.6" = {
      versionPatch = "6";
      sha256 = "d79bc15d456e73a3173a2938f18a17e5149c850ebdedf84a78067f501ee6e16f";
      # Ned Deily
      pgpKeyFingerprint = "0D96 DF4D 4110 E5C4 3FBF  B17F 2D34 7EA6 AA65 421D";
    };
    "3.7" = {
      versionPatch = "0";
      sha256 = "0382996d1ee6aafe59763426cf0139ffebe36984474d0ec4126dd1c40a8b3549";
      # Ned Deily
      pgpKeyFingerprint = "0D96 DF4D 4110 E5C4 3FBF  B17F 2D34 7EA6 AA65 421D";
    };
  };
  source = sources."${channel}";

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
  baseVersionPatch = versionPatch:
    if head (splitString "a" versionPatch) != versionPatch then
      head (splitString "a" versionPatch)
    else if head (splitString "b" versionPatch) != versionPatch then
      head (splitString "b" versionPatch)
    else if head (splitString "rc" versionPatch) != versionPatch then
      head (splitString "rc" versionPatch)
    else
      versionPatch;

  version = "${channel}.${source.versionPatch}";

  tarballUrls = versionPatch: [
    ("https://www.python.org/ftp/python/"
      + "${channel}.${baseVersionPatch versionPatch}/"
      + "Python-${channel}.${versionPatch}.tar.xz")
  ];
in

stdenv.mkDerivation rec {
  name = "python-${version}";

  src = fetchurl {
    url = tarballUrls source.versionPatch;
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

  setupHook = ./setup-hook.sh;

  patches = optionals isPy2 [
    # Patch python to put zero timestamp into pyc
    # if DETERMINISTIC_BUILD env var is set
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "python/python-2.7-deterministic-build.patch";
      sha256 = "7b8ed591008f8f0dafb7f2c95d06404501c84223197fe138df75791f12a9dc24";
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
    #"--${boolWt (!stdenv.cc.isClang)}-gcc"
    #"--enable-big-digits" # py3
    "--${boolWt pydebug}-pydebug"
    #"--with-hash-algorithm" # py3
    (if isPy3 then
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
    "--without-ensurepip" # We have impurities otherwise
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
  '' + optionalString isPy3 ''
    pushd $out/lib/pkgconfig
      if [ ! -f 'python3.pc' ] ; then
        ln -sv python-*.pc python3.pc
      fi
    popd
  '' + ''
    touch $out/lib/python${channel}/test/__init__.py
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
        else
          # FIXME: implement a list of platform tuples instead of
          #        using the targetSystem string.  We may eventually
          #        add a non-GNU system and our tuples differ
          #        from those returned by the autoconf macro.
          "config-${channel}${ifPyDebug}m-${targetSystem}-gnu";
    in ''
      # The lines we are replacing dont include libpython so we parse it out
      LIBS_WITH_PYTHON="$(pkg-config --libs --static $out/lib/pkgconfig/python-${channel}.pc)"
      LIBS="$(echo "$LIBS_WITH_PYTHON" | sed 's,[ ]*\(-L\|-l\)[^ ]*python[^ ]*[ ]*, ,g')"
    '' + ''
      sed -i $out/lib/python${channel}/${configdir}/Makefile \
        -e "s@^LIBS=.*@LIBS= $LIBS@g" \
        -e "s@$NIX_BUILD_TOP@/no-such-path@g"
      sed -i "$out"/bin/python${channel}-config \
        -e "s@^LIBS=\".*\"@LIBS=\"$LIBS_WITH_PYTHON\"@"

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

  # Needed for the setup hook
  inherit
    channel;

  passthru = rec {
    inherit
      isPy2
      isPy3
      version;


    pythonAtLeast = x: versionAtLeast channel x;
    pythonOlder = x: versionOlder channel x;
    isPyPy = false;

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
      inherit (src) outputHashAlgo;
      failEarly = true;
      urls = tarballUrls "0";
      outputHash = "f434053ba1b5c8a5cc597e966ead3c5143012af827fd3f0697d21450bb8d87a6";
      pgpsigUrls = map (n: "${n}.asc") urls;
    };
  };

  meta = with lib; {
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
