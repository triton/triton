{ stdenv
, appdirs
, python
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-appdirs-bootstrap-${appdirs.version}";

  inherit (appdirs) meta src;

  installPhase = ''
    ${python.interpreter} setup.py install --prefix=$out --no-compile
  '';
}
