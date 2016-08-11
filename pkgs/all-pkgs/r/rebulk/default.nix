{ stdenv
, buildPythonPackage
, fetchPyPi

, pytestrunner
, regex
, six

, pytest
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "0.7.3";
in
buildPythonPackage rec {
  name = "rebulk-${version}";

  src = fetchPyPi {
    package = "rebulk";
    inherit version;
    sha256 = "1ee0f672be5cfeed793d294c1cfc078c254fb0966af59191e4f6a0785b3b1697";
  };

  buildInputs = [
    pytestrunner
    regex
    six
  ] ++ optionals doCheck [
    pytest
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
