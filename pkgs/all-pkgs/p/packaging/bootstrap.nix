{ stdenv
, packaging
, python

, pyparsing
, six
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-packaging-bootstrap-${packaging.version}";

  inherit (packaging) meta src;

  nativeBuildInputs = [
    python
  ];

  propagatedBuildInputs = [
    pyparsing
    six
  ];

  installPhase = ''
    ${python.interpreter} setup.py install --prefix=$out --no-compile
  '';
}
