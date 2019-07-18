{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, lazy-object-proxy
, six
, typed-ast
, wrapt
}:

let
  version = "2.2.5";
in
buildPythonPackage rec {
  name = "astroid-${version}";

  src = fetchPyPi {
    package = "astroid";
    inherit version;
    sha256 = "6560e1e1749f68c64a4b5dee4e091fce798d2f0d84ebe638cf0e0585a343acf4";
  };

  propagatedBuildInputs = [
    lazy-object-proxy
    six
    typed-ast
    wrapt
  ];

  meta = with lib; {
    description = "A common base representation of python source code";
    homepage = https://github.com/PyCQA/astroid;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
