{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "17.5.14";
in
buildPythonPackage rec {
  name = "pycountry-${version}";

  src = fetchPyPi {
    package = "pycountry";
    inherit version;
    sha256 = "d31321e59a134aac326ac07d4b2595d63f7e7f755bcb503bdecca2bd1b54ff2f";
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
