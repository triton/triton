{ stdenv
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
    PYTHONPATH="$out/${python.sitePackages}:$PYTHONPATH"
    mkdir -pv $out/${python.sitePackages}
    ${python.interpreter} setup.py install --prefix=$out --no-compile
  '';

  preFixup = ''
    wrapPythonPrograms
  '';
}
