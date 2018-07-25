{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2018.5";
in
buildPythonPackage rec {
  name = "pytz-${version}";

  src = fetchPyPi {
    package = "pytz";
    inherit version;
    sha256 = "ffb9ef1de172603304d9d2819af6f5ece76f2e85ec10692a524dd876e72bf277";
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
