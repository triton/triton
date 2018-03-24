{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
}:

let
  version = "4.2";
in
buildPythonPackage rec {
  name = "pytest-runner-${version}";

  src = fetchPyPi {
    package = "pytest-runner";
    inherit version;
    sha256 = "d23f117be39919f00dd91bffeb4f15e031ec797501b717a245e377aee0f577be";
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
