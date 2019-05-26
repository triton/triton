{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, six
}:

let
  version = "1.9.0";
in
buildPythonPackage rec {
  name = "pyhamcrest-${version}";

  src = fetchPyPi {
    package = "PyHamcrest";
    inherit version;
    sha256 = "8ffaa0a53da57e89de14ced7185ac746227a8894dbd5a3c718bf05ddbd1d56cd";
  };

  propagatedBuildInputs = [
    six
  ];

  meta = with lib; {
    description = "Hamcrest matchers for Python";
    homepage = https://github.com/hamcrest/PyHamcrest;
    license = license.bsdOriginal;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

