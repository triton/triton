{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2017.2";
in
buildPythonPackage rec {
  name = "pytz-${version}";

  src = fetchPyPi {
    package = "pytz";
    inherit version;
    type = ".zip";
    sha256 = "f5c056e8f62d45ba8215e5cb8f50dfccb198b4b9fbea8500674f3443e4689589";
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
