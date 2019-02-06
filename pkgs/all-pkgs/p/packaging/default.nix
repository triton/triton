{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyparsing
, six
}:

let
  version = "19.0";
in
buildPythonPackage rec {
  name = "packaging-${version}";

  src = fetchPyPi {
    package = "packaging";
    inherit version;
    sha256 = "0c98a5d0be38ed775798ece1b9727178c4469d9c3b4ada66e8e6b7849f8732af";
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
