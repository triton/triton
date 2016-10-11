{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2016.7";
in
buildPythonPackage rec {
  name = "pytz-${version}";

  src = fetchPyPi {
    package = "pytz";
    inherit version;
    sha256 = "8787de03f35f31699bcaf127e56ad14c00647965ed24d72dbaca87c6e4f843a3";
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
