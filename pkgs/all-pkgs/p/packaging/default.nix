{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyparsing
, six
}:

let
  version = "17.1";
in
buildPythonPackage rec {
  name = "packaging-${version}";

  src = fetchPyPi {
    package = "packaging";
    inherit version;
    sha256 = "f019b770dd64e585a99714f1fd5e01c7a8f11b45635aa953fd41c689a657375b";
  };

  propagatedBuildInputs = [
    pyparsing
    six
  ];

  passthru = {
    inherit version;
  };

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
