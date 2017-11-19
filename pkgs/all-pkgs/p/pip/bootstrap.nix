{ stdenv
, pip
, python
, wrapPython

, setuptools
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-pip-bootstrap-${pip.version}";

  inherit (pip) meta src;

  nativeBuildInputs = [
    python
    setuptools
    wrapPython
  ];

  installPhase = ''
    PYTHONPATH="$out/${python.sitePackages}''${PYTHONPATH:+:}$PYTHONPATH"
    mkdir -pv $out/${python.sitePackages}
    ${python.interpreter} setup.py install --prefix=$out --no-compile
  '';

  preFixup = ''
    wrapPythonPrograms
  '';
}
