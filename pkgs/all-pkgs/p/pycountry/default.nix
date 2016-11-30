{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "16.11.27.1";
in
buildPythonPackage rec {
  name = "pycountry-${version}";

  src = fetchPyPi {
    package = "pycountry";
    inherit version;
    sha256 = "08c17eec56bba50f8d66529ce90fc343d75d77280537141ee65e61b41936aa1d";
  };

  doCheck = true;

  meta = with stdenv.lib; {
    description = "ISO country, subdivision, language, currency & script definitions";
    homepage = https://bitbucket.org/flyingcircus/pycountry;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
