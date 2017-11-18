{ stdenv
, pyparsing
, python
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-pyparsing-bootstrap-${pyparsing.version}";

  inherit (pyparsing) meta src;

  installPhase = ''
    ${python.interpreter} setup.py install --prefix=$out --no-compile
  '';
}
