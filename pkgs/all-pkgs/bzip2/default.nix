{ stdenv
, fetchurl

, static ? false
, shared ? true
}:

assert shared || static;

let
  inherit (stdenv.lib) optionals optionalString;
in
stdenv.mkDerivation rec {
  name = "bzip2-${version}";
  version = "1.0.6";

  src = fetchurl {
    url = "http://www.bzip.org/${version}/${name}.tar.gz";
    sha256 = "1kfrc7f0ja9fdn6j1y6yir6li818npy6217hvr3wzmnmzhs8z152";
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
    homepage = "http://www.bzip.org";
    description = "high-quality data compression program";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
