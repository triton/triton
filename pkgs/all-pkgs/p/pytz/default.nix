{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2016.10";
in
buildPythonPackage rec {
  name = "pytz-${version}";

  src = fetchPyPi {
    package = "pytz";
    inherit version;
    sha256 = "9a43e20aa537cfad8fe7a1715165c91cb4a6935d40947f2d070e4c80f2dcd22b";
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
