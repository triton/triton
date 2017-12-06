{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, setuptools-scm
}:

let
  version = "1.4.3";
in
buildPythonPackage rec {
  name = "jaraco-classes-${version}";

  src = fetchPyPi {
    package = "jaraco.classes";
    inherit version;
    sha256 = "e347f2b502521bfc35c57ab4695e8b6d7371625c392a0ca0d46742ee93359d3e";
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
