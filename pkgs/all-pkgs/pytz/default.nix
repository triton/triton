{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "pytz-${version}";
  version = "2016.4";

  src = fetchPyPi {
    package = "pytz";
    inherit version;
    sha256 = "c823de61ff40d1996fe087cec343e0503881ca641b897e0f9b86c7683a0bfee1";
  };

  doCheck = true;

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
