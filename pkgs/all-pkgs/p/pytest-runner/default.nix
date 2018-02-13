{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
}:

let
  version = "4.0";
in
buildPythonPackage rec {
  name = "pytest-runner-${version}";

  src = fetchPyPi {
    package = "pytest-runner";
    inherit version;
    sha256 = "183f3745561b1e00ea51cd97634ba5c540848ab4aa8016a81faba7fb7f33ec76";
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
