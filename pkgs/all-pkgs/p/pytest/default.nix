{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, py
, setuptools-scm
}:

let
  version = "3.3.1";
in
buildPythonPackage rec {
  name = "pytest-${version}";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "cf8436dc59d8695346fcd3ab296de46425ecab00d64096cebe79fb51ecb2eb93";
  };

  propagatedBuildInputs = [
    setuptools-scm
    py
  ];

  meta = with lib; {
    description = "Simple powerful testing framework for Python";
    homepage = https://pytest.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
