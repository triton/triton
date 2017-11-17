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

let
  inherit (lib)
    makeSearchPath;
in
stdenv.mkDerivation rec {
  name = "${python.executable}-setuptools-bootstrap-${setuptools.version}";

  inherit (setuptools) meta src;

  nativeBuildInputs = [
    python
    unzip
    wrapPython
  ];

  propagatedBuildInputs = [
    appdirs
    packaging
    pyparsing
    six
  ];

  depsSearchPath = makeSearchPath "${python.sitePackages}" propagatedBuildInputs;

  postPatch = /* Remove vendored sources, otherwise no errors are returned */ ''
    rm -rv pkg_resources/_vendor/
  '' + ''
    sed -i '/pip.main(args)/d' bootstrap.py
  '';

  installPhase = ''
    export SETUPTOOLS_INSTALL_WINDOWS_SPECIFIC_FILES=0
    ${python.interpreter} bootstrap.py
    ${python.interpreter} setup.py install --root=/ --prefix=$out --no-compile
  '';

  preFixup = ''
    wrapPythonPrograms
  '';

}
