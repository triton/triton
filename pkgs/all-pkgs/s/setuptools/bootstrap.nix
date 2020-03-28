{ stdenv
, fetchPyPi
, lib
, python
, setuptools
, unzip
, wrapPython

, appdirs
, packaging
, pyparsing
, six
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-setuptools-bootstrap-${setuptools.version}";

  inherit (setuptools) meta src;

  nativeBuildInputs = [
    unzip
    wrapPython
  ];

  propagatedBuildInputs = [
    python
  ];

  installPhase = ''
    export SETUPTOOLS_INSTALL_WINDOWS_SPECIFIC_FILES=0
    PYTHONPATH="$out/${python.sitePackages}''${PYTHONPATH:+:}$PYTHONPATH"
    mkdir -pv $out/${python.sitePackages}
    ${python.interpreter} bootstrap.py
    ${python.interpreter} setup.py install --prefix=$out --no-compile
  '';

  preFixup = ''
    wrapPythonPrograms
  '';

}
