{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyparsing
, six
}:

let
  version = "20.3";
in
buildPythonPackage rec {
  name = "packaging-${version}";

  src = fetchPyPi {
    package = "packaging";
    inherit version;
    sha256 = "3c292b474fda1671ec57d46d739d072bfd495a4f51ad01a055121d81e952b7a3";
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
