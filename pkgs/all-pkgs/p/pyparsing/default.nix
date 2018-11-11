{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.3.0";
in
buildPythonPackage rec {
  name = "pyparsing-${version}";

  src = fetchPyPi {
    package = "pyparsing";
    inherit version;
    sha256 = "f353aab21fd474459d97b709e527b5571314ee5f067441dc9f88e33eecd96592";
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
