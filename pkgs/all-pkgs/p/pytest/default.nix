{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, py
, setuptools-scm
}:

let
  version = "3.4.0";
in
buildPythonPackage rec {
  name = "pytest-${version}";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "6074ea3b9c999bd6d0df5fa9d12dd95ccd23550df2a582f5f5b848331d2e82ca";
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
