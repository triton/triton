{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pythonPackages
}:

let
  version = "1.17.0";
in
buildPythonPackage rec {
  name = "setuptools-scm-${version}";

  src = fetchPyPi {
    package = "setuptools_scm";
    inherit version;
    sha256 = "70a4cf5584e966ae92f54a764e6437af992ba42ac4bca7eb37cc5d02b98ec40a";
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
