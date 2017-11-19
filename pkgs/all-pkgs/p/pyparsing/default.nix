{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.2.0";
in
buildPythonPackage rec {
  name = "pyparsing-${version}";

  src = fetchPyPi {
    package = "pyparsing";
    inherit version;
    sha256 = "0832bcf47acd283788593e7a0f542407bd9550a55a8a8435214a1960e04bcb04";
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
