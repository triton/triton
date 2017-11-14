{ stdenv
, lib
, unzip

, python
, setuptools
, wrapPython
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-setuptools-egg-${setuptools.version}";

  inherit (setuptools) meta src;

  nativeBuildInputs = [
    python
    unzip
    wrapPython
  ];

  installPhase = ''
    dst=$out/${python.sitePackages}
    mkdir -pv $dst
    PYTHONPATH="$dst" ${python.interpreter} setup.py install --prefix=$out
  '';

  preFixup = ''
    wrapPythonPrograms
  '';
}
