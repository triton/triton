{ stdenv
, fetchFromGitHub
, python

, pip
, setuptools
, unzip
, wheel
, wrapPython
}:

let
  inherit (pip)
    version;
in
stdenv.mkDerivation rec {
  name = "python-${python.version}-pip-bootstrap-${version}";

  inherit (pip) src;

  nativeBuildInputs = [
    python
    setuptools
    wheel
    wrapPython
    unzip
  ];

  buildPhase = ''
    ${python.interpreter} setup.py bdist_wheel
  '';

  installPhase = ''
    pushd dist
      mkdir -pv $out/${python.sitePackages}
      unzip -d $out/${python.sitePackages} pip-*.whl
      mkdir -pv $out/bin
      echo '${python.interpreter} -m pip "$@"' > $out/bin/pip
      chmod +x $out/bin/pip
    popd
  '';

  preFixup = ''
    wrapPythonPrograms $out/bin
  '';
}
