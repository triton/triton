{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, setuptools-scm
}:

let
  version = "1.5";
in
buildPythonPackage rec {
  name = "jaraco-classes-${version}";

  src = fetchPyPi {
    package = "jaraco.classes";
    inherit version;
    sha256 = "d101c45efd518a3ed76409a23ad2319bafeda13c3252395fe4d8ec195dd45f00";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  meta = with lib; {
    description = "Utility functions for Python class constructs";
    homepage = https://github.com/jaraco/jaraco.classes;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
