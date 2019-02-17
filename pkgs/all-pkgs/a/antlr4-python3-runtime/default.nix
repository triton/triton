{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, python
}:

let
  version = "4.7.2";
in
buildPythonPackage rec {
  name = "antlr4-python3-runtime-${version}";

  src = fetchPyPi {
    package = "antlr4-python3-runtime";
    inherit version;
    sha256 = "168cdcec8fb9152e84a87ca6fd261b3d54c8f6358f42ab3b813b14a7193bb50b";
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

