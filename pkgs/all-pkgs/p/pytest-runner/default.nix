{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
}:

let
  version = "2.11.1";
in
buildPythonPackage rec {
  name = "pytest-runner-${version}";

  src = fetchPyPi {
    package = "pytest-runner";
    inherit version;
    sha256 = "983a31eab45e375240e250161a556163bc8d250edaba97960909338c273a89b3";
  };

  propagatedBuildInputs = [
    setuptools-scm
  ];

  doCheck = true;

  meta = with lib; {
    description = "Invoke py.test as distutils command with dependency resolution";
    homepage = https://github.com/pytest-dev/pytest-runner;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
