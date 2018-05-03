{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pythonPackages
}:

let
  version = "2.0.0";
in
buildPythonPackage rec {
  name = "setuptools-scm-${version}";

  src = fetchPyPi {
    package = "setuptools_scm";
    inherit version;
    sha256 = "638627655ec4625b7a055a5b65f44e88121fce05a281a1597abd6a9f8c04139b";
  };

  meta = with lib; {
    description = "Handles managing python package versions in scm metadata";
    homepage = https://bitbucket.org/pypa/setuptools_scm/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
