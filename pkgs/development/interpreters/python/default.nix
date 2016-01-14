{ stdenv
, fetchurl

, bzip2
, db
, expat
, gdbm
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
, self ? null
}:

with {
  inherit (stdenv)
    isLinux;
  inherit (stdenv.lib)
    concatStringsSep
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

stdenv.mkDerivation rec {
  name = "python-${version}";
  inherit versionMajor;
  inherit versionMinor;
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz";
    inherit sha256;
  };

  setupHook =
    if channel == "2.7" then
      ./setup-hook-2.7.sh
    else if channel == "3.2" then
      ./setup-hook-3.2.sh
    else if channel == "3.3" then
      ./setup-hook-3.3.sh
    else if channel == "3.4" then
      ./setup-hook-3.4.sh
    else if channel == "3.5" then
      ./setup-hook-3.5.sh
    else
      throw "unsupported version";

  patches = optionals isPy2 [
    # patch python to put zero timestamp into pyc
    # if DETERMINISTIC_BUILD env var is set
    ./patches/python-2.7-deterministic-build.patch
    ./patches/python-2.7-properly-detect-curses.patch
    # Python recompiles a Python if the mtime stored *in* the
    # pyc/pyo file differs from the mtime of the source file.  This
    # doesn't work in Nix because Nix changes the mtime of files in
    # the Nix store to 1.  So treat that as a special case.
    ./patches/python-2.x-nix-store-mtime.patch
    # Look in C_INCLUDE_PATH and LIBRARY_PATH for stuff.
    ./patches/python-2.x-search-path.patch
  ];

  postPatch = ''
    # improve purity
    for i in /usr /sw /opt /pkg ; do
      substituteInPlace ./setup.py \
        --replace $i /no-such-path
    done
  '' + optionalString (stdenv ? cc && stdenv.cc.libc != null && isPy2) ''
    for i in Lib/plat-*/regen ; do
      substituteInPlace $i \
        --replace /usr/include/ ${stdenv.cc.libc}/include/
    done
  '';

  configureFlags = [
    "--disable-universalsdk"
    "--disable-framework"
    "--enable-shared"
    "--disable-profiling"
    (verFlag isPy2 "--disable-toolbox-glue")
    (verFlag isPy3 "--enable-loadable-sqlite-extensions")
    "--enable-ipv6"
    (verFlag isPy2 "--enable-unicode=ucs4")
    #(verFlag isPy3 "--enable-big-digits")
    (wtFlag "gcc" (!stdenv.cc.isClang) null)
    #(verFlag isPy3 "--with-hash-algorithm")
    # Flag is not a boolean
    (verFlag (versionAtLeast versionMajor "3.5")
      (if stdenv.cc.isClang then
        "--with-address-sanitizer"
       else
         null))
    "--with-system-expat"
    "--with-system-ffi"
    (verFlag isPy3 "--with-system-libmpdec")
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

  # Should this be stdenv.cc.isGnu???
  NIX_LDFLAGS = optionalString isLinux "-lgcc_s";

  preConfigure = ''
    # improve purity
    for i in /usr /sw /opt /pkg ; do
      substituteInPlace ./setup.py \
        --replace $i /no-such-path
    done

    configureFlagsArray+=(
      CPPFLAGS="${concatStringsSep " " (map (p: "-I${p}/include") buildInputs)}"
      LDFLAGS="${concatStringsSep " " (map (p: "-L${p}/lib") buildInputs)}"
      LIBS="-lcrypt ${optionalString (ncurses != null) "-lncurses"}"
    )
  '';

  buildInputs = [
    bzip2
    db
    expat
    gdbm
    lzma
    ncurses
    openssl
    readline
    sqlite
    zlib
  ];

  # tkinter is disabled
  modules = "_bsddb,_curses,_curses_panel,_crypt,_gdbm,_sqlite3,_readline";

  postBuild = optionalString isPy2 ''
    # This uses the python interpreter that was just built to run the
    # script to build the modules
    substituteInPlace setup.py --replace 'self.extensions = extensions' \
      'self.extensions = [ext for ext in self.extensions if ext.name in ["${modules}"]]'

    export C_INCLUDE_PATH="${
      concatStringsSep ":" (map (p: "${p}/include") buildInputs)}";
    export LIBRARY_PATH="${
      concatStringsSep ":" (map (p: "${p}/lib") buildInputs)}";

    export LD_LIBRARY_PATH="$(pwd)";

    ./python setup.py build_ext
    [ -z "$(find build -name '*_failed.so' -print)" ]
  '';

  postInstall = ''
    # needed for some packages, especially packages that backport functionality
    # to 2.x from 3.x
    for item in $out/lib/python${versionMajor}/test/* ; do
      if [[ "$item" != */test_support.py* ]]; then
        rm -rvf "$item"
      else
        echo $item
      fi
    done
    touch $out/lib/python${versionMajor}/test/__init__.py

    paxmark E $out/bin/python${versionMajor}
  '' + optionalString isPy2 ''
    # Install modules
    dest=$out/lib/python${versionMajor}/site-packages
    mkdir -p $dest
    cp -p $(find . -name "*.so") $dest/
  '' + optionalString isPy2 ''
    ln -s $out/lib/python${versionMajor}/pdb.py $out/bin/pdb
    ln -s $out/lib/python${versionMajor}/pdb.py $out/bin/pdb${versionMajor}
    ln -s $out/share/man/man1/{python2.7.1.gz,python.1.gz}
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
    isPy2 = versionOlder versionMajor "3.0";
    isPy3 = versionAtLeast versionMajor "3.0";
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
