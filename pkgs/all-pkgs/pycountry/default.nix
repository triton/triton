{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "pycountry-${version}";
  version = "1.20";

  src = fetchPyPi {
    package = "pycountry";
    inherit version;
    sha256 = "0588efa3171e1d5e4cc96fce569ac865964285fdc8dbdc0860844f74598d1f98";
  };

  doCheck = true;

  meta = with stdenv.lib; {
    description = "ISO country, subdivision, language, currency and script definitions";
    homepage = https://bitbucket.org/flyingcircus/pycountry;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
