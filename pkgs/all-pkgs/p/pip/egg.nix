{ stdenv
, lib
, pip
, python
, setuptools_egg
, wrapPython
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-pip-egg-${pip.version}";

  inherit (pip) meta src;

  nativeBuildInputs = [
    python
    setuptools_egg
    wrapPython
  ];

  installPhase = ''
    mkdir -pv "$out/${python.sitePackages}"
    export PYTHONPATH="$out/${python.sitePackages}:$PYTHONPATH"
    ${python.interpreter} setup.py install --prefix=$out
  '';

  preFixup = ''
    wrapPythonPrograms
  '';
}
