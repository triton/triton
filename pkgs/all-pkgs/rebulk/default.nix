{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
in

buildPythonPackage rec {
  name = "rebulk-${version}";
  version = "0.7.2";

  src = fetchPyPi {
    package = "rebulk";
    inherit version;
    sha256 = "ee4c75819c6d0eeedb531fb22c214e50f303ccc4703f27db1f993cd082ed5a20";
  };

  buildInputs = [
    pythonPackages.pytestrunner
    pythonPackages.regex
    pythonPackages.six
  ] ++ optionals doCheck [
    pythonPackages.pytest
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Define search patterns in bulk to perform matching on any string";
    homepage = https://github.com/Toilal/rebulk;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
