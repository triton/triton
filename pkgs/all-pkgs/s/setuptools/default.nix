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

  version = "38.2.4";
in
buildPythonPackage rec {
  name = "setuptools-${version}";

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    type = ".zip";
    sha256 = "9c671a6291a5b1171fb9da81665eb4f9625c7dbddc613d82abdc6002a4bce896";
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
