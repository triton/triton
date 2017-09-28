{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "17.9.23";
in
buildPythonPackage rec {
  name = "pycountry-${version}";

  src = fetchPyPi {
    package = "pycountry";
    inherit version;
    sha256 = "173c5e3a8884c5616c6595078cc8f27e65ce59c6d9aa8864bace0c6b1281c57a";
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
