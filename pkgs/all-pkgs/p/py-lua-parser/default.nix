{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, python

, antlr4-python3-runtime
}:

let
  version = "2.0.2";
in
buildPythonPackage rec {
  name = "py-lua-parser-${version}";

  src = fetchPyPi {
    package = "luaparser";
    inherit version;
    sha256 = "8b4721dc79e9474dff381b750812efa7df7749ec3c13c8a5821f463ca6851408";
  };

  propagatedBuildInputs = [
    antlr4-python3-runtime
  ];

  disabled = python.pythonOlder "3";

  meta = with lib; {
    description = "A Lua parser and AST builder";
    homepage = https://github.com/boolangery/py-lua-parser;
    license = licenses.mit;
    maintianers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

