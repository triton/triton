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
    PYTHONPATH="${setuptools}/${python.sitePackages}:${setuptools.depsSearchPath}" \
      ${python.interpreter} setup.py install --root=/ --prefix=$out --no-compile
  '';

  preFixup = ''
    wrapPythonPrograms
  '';
}
