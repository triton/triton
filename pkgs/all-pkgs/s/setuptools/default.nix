{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, python
, unzip

, appdirs
, packaging
, pyparsing
, six
}:

let
  inherit (lib)
    makeSearchPath;

  version = "36.7.2";
in
buildPythonPackage rec {
  name = "setuptools-${version}";

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    type = ".zip";
    sha256 = "ad86fd8dd09c285c33b4c5b82bbc21d21883637faef78b0ab58fa9984847220d";
  };

  nativeBuildInputs = [
    unzip
  ];

  propagatedBuildInputs = [
    appdirs
    packaging
    pyparsing
    six
  ];

  postPatch = /* Remove vendored sources, otherwise no errors are returned */ ''
    rm -rv pkg_resources/_vendor/
  '';

  preBuild = ''
    ${python.interpreter} bootstrap.py
  '';

  passthru = {
    inherit version;
  };

  meta = with lib; {
    description = "Utilities to facilitate the installation of Python packages";
    homepage = http://pypi.python.org/pypi/setuptools;
    license = licenses.zpt20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}
