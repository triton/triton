{ stdenv
, fetchurl
, gnum4

, bootstrap ? false
}:

let
  inherit (stdenv.lib)
    optionalString;

  version = "3.0.4";
in
stdenv.mkDerivation rec {
  name = "${if bootstrap then "bootstrap-" else ""}bison-${version}";

  src = fetchurl {
    url = "mirror://gnu/bison/bison-${version}.tar.xz";
    hashOutput = false;
    sha256 = "a72428c7917bdf9fa93cb8181c971b6e22834125848cf1d03ce10b1bb0716fe1";
  };

  nativeBuildInputs = [
    gnum4
  ];

  # We need this for bison to work correctly when being
  # used during the build process
  propagatedBuildInputs = [
    gnum4
  ];

  # We don't want a dependency on perl since it is horrible to build
  # during the early bootstrap when we need bison
  preConfigure = ''
    mkdir -p "$TMPDIR"/pbin
    echo "#! ${stdenv.shell}" >> "$TMPDIR"/pbin/perl
    echo "echo 0 > $srcRoot/examples/extracted.stamp" >> "$TMPDIR"/pbin/perl
    echo "echo 0 > $srcRoot/examples/extracted.stamp.tmp" >> "$TMPDIR"/pbin/perl
    chmod +x "$TMPDIR"/pbin/perl
    export PATH="$TMPDIR/pbin:$PATH"

    touch examples/calc++/calc++-driver.cc
    touch examples/calc++/calc++-driver.hh
    touch examples/calc++/calc++-scanner.ll
    touch examples/calc++/calc++.cc
    touch examples/calc++/calc++-parser.yy
    touch examples/mfcalc/calc.h
    touch examples/mfcalc/mfcalc.y
    touch examples/rpcalc/rpcalc.y
  '';

  postInstall = ''
    rm -rf $out/share/doc
  '';

  preFixup = optionalString bootstrap ''
    find "$out" -not -name bin -and -not -name share -mindepth 1 -maxdepth 1 | xargs -r rm -r
  '';

  setupHook = ./setup-hook.sh;

  ccFixFlags = !bootstrap;
  createBuildRoot = false;  # Build is broken with a separate build dir
  buildDirCheck = !bootstrap;

  meta = with stdenv.lib; {
    description = "Yacc-compatible parser generator";
    homepage = "http://www.gnu.org/software/bison/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
