{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2018.4";
in
buildPythonPackage rec {
  name = "pytz-${version}";

  src = fetchPyPi {
    package = "pytz";
    inherit version;
    sha256 = "c06425302f2cf668f1bba7a0a03f3c1d34d4ebeef2c72003da308b3947c7f749";
  };

  meta = with lib; {
    description = "World timezone definitions, modern and historical";
    homepage = http://pythonhosted.org/pytz;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
