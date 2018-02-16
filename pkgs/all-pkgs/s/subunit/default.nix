{ stdenv
, fetchurl
, lib
, makeWrapper
, perl
, python2Packages

, check
, cppunit

, type ? ""
}:

let
  inherit (lib)
    optionals
    optionalString;

  major = "1.2";
  version = "${major}.0";
in
stdenv.mkDerivation rec {
  name = "subunit-${version}";

  src = fetchurl {
    url = "https://launchpad.net/subunit/trunk/${major}/+download/${name}.tar.gz";
    sha256 = "27f0561297a7d56d85a8f5491f47e44303d0bb1d99c5627486774ea1bcb3d5c3";
  };

  nativeBuildInputs = [
    python2Packages.python
  ] ++ optionals (type != "lib") [
    makeWrapper
    perl
    python2Packages.wrapPython
  ] ++ optionals doCheck [
    python2Packages.testscenarios
    python2Packages.testtools
  ];

  buildInputs = [
    cppunit
  ] ++ optionals (type != "lib") [
    check
  ];

  pythonPath = optionalString (type != "lib") [
    python2Packages.testtools
  ];

  CHECK_CFLAGS = optionalString (!doCheck) "-I/no-such-path";
  CHECK_LIBS = optionalString (!doCheck) "-lno-such-lib";

  postPatch = ''
    sed -i '$atriton-build: $(lib_LTLIBRARIES) $(pcdata_DATA)' Makefile.in
  '';

  buildFlags = optionals (type == "lib") [
    "triton-build"
  ];

  installTargets = optionals (type == "lib") [
    "install-libLTLIBRARIES"
    "install-pcdataDATA"
    "install-include_subunitHEADERS"
  ];

  # Currently failing to test out
  #doCheck = type != "lib";
  doCheck = false;

  preFixup = optionalString (type != "lib") ''
    find "$out"/lib -name perllocal.pod -exec \
      sed -i "s,EXE_FILES: [^>]*subunit-diff,EXE_FILES: $out/bin/subunit-diff," {} \;
    
    wrapProgram "$out"/bin/subunit-diff \
      --prefix PERL5LIB : "$out/${perl.libPrefix}"

    wrapPythonPrograms
  '';

  meta = with lib; {
    description = "A streaming protocol for test results";
    homepage = https://launchpad.net/subunit;
    license = licenses.asl20;
    platforms = with platforms;
      x86_64-linux;
  };
}
