{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
in

buildPythonPackage rec {
  name = "wheel-${version}";
  version = "0.29.0";

  src = fetchPyPi {
    package = "wheel";
    inherit version;
    sha256 = "1ebb8ad7e26b448e9caa4773d2357849bf80ff9e313964bcaf79cbf0201a1648";
  };

  buildInputs = optionals doCheck [
    pythonPackages.coverage
    pythonPackages.pytest
    pythonPackages.pytestcov
  ];

  propagatedBuildInputs = [
    pythonPackages.jsonschema
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "A built-package format for Python";
    homepage = https://bitbucket.org/pypa/wheel/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
