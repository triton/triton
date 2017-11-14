{ stdenv
, lib
, python
, setuptools_egg
, wheel
, wrapPython
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-wheel-egg-${wheel.version}";

  inherit (wheel) meta src;

  nativeBuildInputs = [
    python
    setuptools_egg
    wrapPython
  ];

  installPhase = ''
    mkdir -pv $out/${python.sitePackages}
    export PYTHONPATH="$out/${python.sitePackages}:$PYTHONPATH"
    ${python.interpreter} setup.py install --prefix=$out
  '';

  preFixup = ''
    wrapPythonPrograms
  '';
}
