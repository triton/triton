{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "17.1.8";
in
buildPythonPackage rec {
  name = "pycountry-${version}";

  src = fetchPyPi {
    package = "pycountry";
    inherit version;
    sha256 = "c5ccad49e47caee92779bf83da81565159b1fe3d8f48b063068ac118b73dd1f8";
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
