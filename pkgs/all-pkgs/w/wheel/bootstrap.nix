{ stdenv
, fetchPyPi
, lib
, python
, setuptools
, wheel
, wrapPython
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-wheel-bootstrap-${wheel.version}";

  inherit (wheel) meta src;

  nativeBuildInputs = [
    python
    setuptools
    wrapPython
  ];

  installPhase = ''
    ${python.interpreter} setup.py install --root=/ --prefix=$out --no-compile
  '';

  preFixup = ''
    wrapPythonPrograms
  '';
}
