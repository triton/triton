{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "18.2.23";
in
buildPythonPackage rec {
  name = "pycountry-${version}";

  src = fetchPyPi {
    package = "pycountry";
    inherit version;
    sha256 = "46e4b1a21516e41fe6f8c0ef7a9876da8ce9ac3f719e3fed79cf79fd9b6206ee";
  };

  doCheck = true;

  meta = with lib; {
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
