{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "18.5.20";
in
buildPythonPackage rec {
  name = "pycountry-${version}";

  src = fetchPyPi {
    package = "pycountry";
    inherit version;
    sha256 = "d2da27a75d1fcf90e0f116dd5aabb6e7c9ae987f6e205e6ff9096fa8cd9bfccb";
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
