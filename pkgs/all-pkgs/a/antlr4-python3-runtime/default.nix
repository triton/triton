{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, python
}:

let
  version = "4.7.1";
in
buildPythonPackage rec {
  name = "antlr4-python3-runtime-${version}";

  src = fetchPyPi {
    package = "antlr4-python3-runtime";
    inherit version;
    sha256 = "1b26b72c4492cef310542da10bf6b2ab4aa1775618fc6003f75b55ae9eaa3fd3";
  };

  disabled = python.pythonOlder "3";

  meta = with lib; {
    description = "ANTLR 4 runtime for Python 3";
    homepage = https://www.antlr.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

