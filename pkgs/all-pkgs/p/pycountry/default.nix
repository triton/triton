{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "16.11.8";
in
buildPythonPackage rec {
  name = "pycountry-${version}";

  src = fetchPyPi {
    package = "pycountry";
    inherit version;
    sha256 = "c9a0536699dfb46fb43ae1449999a921a79361030773bc3d35e00abfecb437c2";
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
