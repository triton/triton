{ stdenv
, fetchurl

, static ? true
, shared ? true
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  version = "1.0.6";
in

assert shared || static;

stdenv.mkDerivation rec {
  name = "bzip2-${version}";

  src = fetchurl {
    url = "http://www.bzip.org/${version}/${name}.tar.gz";
    multihash = "Qmdj4eF9zXRyey7hEvGZCvEzumeeiavq4NeFHFYtwaACdk";
    md5Confirm = "00b516f4704d4a7cb50a1d97e6e8e15b";
    sha256 = "a2848f34fcd5d6cf47def00461fcb528a0484d8edef8208d6d2e2909dc61d9cd";
  };

  # The builder also always builds the static library
  postPatch = ''
    sed -e 's,\(:.*\)libbz2.a,\1,g' -i Makefile
  '';

  # The shared library is built from a separate makefile
  preBuild = optionalString shared ''
    local actualMakeFlags
    actualMakeFlags=()
    local makefile
    makefile="Makefile-libbz2_so"
    commonMakeFlags "preBuild"
    printMakeFlags "preBuild"
    make "''${actualMakeFlags[@]}"

    # Make sure we have a generic .so
    test -f "libbz2.so.${version}"
    ln -sv "libbz2.so.${version}" libbz2.so

    # The output binaries are used as part of the build so allow
    # them to load the .so
    export LD_LIBRARY_PATH="$(pwd)"
  '' + optionalString static ''
    local actualMakeFlags
    actualMakeFlags=()
    local makefile
    makefile="Makefile"
    commonMakeFlags "preBuild"
    actualMakeFlags+=("libbz2.a")
    printMakeFlags "preBuild"
    make "''${actualMakeFlags[@]}"
  '';

  buildFlags = [
    "bzip2"
    "bzip2recover"
  ];

  linkStatic = !shared;

  # The built in installer is a bit wonky so we will do it ourselves
  installPhase = ''
    mkdir -p "$out/"{bin,share/man/man1,include,lib}

    chmod +x bzgrep bzmore bzdiff
    cp bzip2 bzip2recover bzgrep bzmore bzdiff $out/bin
    ln -sv bzip2 $out/bin/bunzip2
    ln -sv bzip2 $out/bin/bzcat
    ln -sv bzgrep $out/bin/bzegrep
    ln -sv bzgrep $out/bin/bzfgrep
    ln -sv bzmore $out/bin/bzless
    ln -sv bzdiff $out/bin/bzcmp

    cp bzlib.h $out/include

    cp bzip2.1 bzgrep.1 bzmore.1 bzdiff.1 $out/share/man/man1
	  echo ".so man1/bzip2.1" > $out/share/man/man1/bunzip2.1
	  echo ".so man1/bzip2.1" > $out/share/man/man1/bzcat.1
	  echo ".so man1/bzgrep.1" > $out/share/man/man1/bzegrep.1
   	echo ".so man1/bzgrep.1" > $out/share/man/man1/bzfgrep.1
	  echo ".so man1/bzmore.1" > $out/share/man/man1/bzless.1
	  echo ".so man1/bzdiff.1" > $out/share/man/man1/bzcmp.1
  '' + optionalString shared ''
    cp *.so* $out/lib
  '' + optionalString static ''
    cp *.a $out/lib
  '';

  meta = with stdenv.lib; {
    description = "high-quality data compression program";
    homepage = "http://www.bzip.org";
    license = licenses.free; # bzip2
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
