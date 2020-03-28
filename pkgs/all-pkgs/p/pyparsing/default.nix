{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.4.6";
in
buildPythonPackage rec {
  name = "pyparsing-${version}";

  src = fetchPyPi {
    package = "pyparsing";
    inherit version;
    sha256 = "4c830582a84fb022400b85429791bc551f1f4871c33f23e44f353119e92f969f";
  };

  passthru = {
    inherit version;
  };

  meta = with lib; {
    description = "Python parsing module";
    homepage = http://pyparsing.wikispaces.com/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
