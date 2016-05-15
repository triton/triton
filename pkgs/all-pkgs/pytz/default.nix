{ stdenv
, buildPythonPackage
, fetchurl
}:

buildPythonPackage rec {
  name = "pytz-2016.3";

  src = fetchurl {
    url = "mirror://pypi/p/pytz/${name}.tar.gz";
    sha256 = "3449da19051655d4c0bb5c37191331748bcad15804d81676a88451ef299370a8";
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
