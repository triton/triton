{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pythonPackages
}:

let
  version = "1.15.6";
in
buildPythonPackage rec {
  name = "setuptools-scm-${version}";

  src = fetchPyPi {
    package = "setuptools_scm";
    inherit version;
    sha256 = "49ab4685589986a42da85706b3311a2f74f1af567d39fee6cb1e088d7a75fb5f";
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
