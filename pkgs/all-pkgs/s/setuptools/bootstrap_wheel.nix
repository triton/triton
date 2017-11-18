{ stdenv
, fetchPyPi
, setuptools
, unzip
, wrapPython

, python
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-setuptools-bootstrap-wheel-${setuptools.version}";

  inherit (setuptools) meta src;

  nativeBuildInputs = [
    unzip
  ];

  buildInputs = [
    python
    wrapPython
  ];

  installPhase = ''
    dst=$out/${python.sitePackages}
    mkdir -pv $dst
    export PYTHONPATH="$dst:$PYTHONPATH"
    ${python.interpreter} setup.py install --prefix=$out --no-compile
    wrapPythonPrograms
  '';
}
