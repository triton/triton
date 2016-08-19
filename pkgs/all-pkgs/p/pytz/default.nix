{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2016.6.1";
in
buildPythonPackage rec {
  name = "pytz-${version}";

  src = fetchPyPi {
    package = "pytz";
    inherit version;
    sha256 = "6f57732f0f8849817e9853eb9d50d85d1ebb1404f702dbc44ee627c642a486ca";
  };

  meta = with stdenv.lib; {
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
