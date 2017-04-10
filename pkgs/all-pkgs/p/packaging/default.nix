{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyparsing
, six
}:

let
  version = "16.8";
in
buildPythonPackage rec {
  name = "packaging-${version}";

  src = fetchPyPi {
    package = "packaging";
    inherit version;
    sha256 = "5d50835fdf0a7edf0b55e311b7c887786504efea1177abd7e69329a8e5ea619e";
  };

  propagatedBuildInputs = [
    pyparsing
    six
  ];

  meta = with lib; {
    description = "Core utilities for Python packages";
    homepage = https://github.com/pypa/packaging;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
