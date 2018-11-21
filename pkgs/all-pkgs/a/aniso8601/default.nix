{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, python-dateutil
}:

let
  version = "4.0.1";
in
buildPythonPackage rec {
  name = "aniso8601-${version}";

  src = fetchPyPi {
    package = "aniso8601";
    inherit version;
    sha256 = "e7560de91bf00baa712b2550a2fdebf0188c5fce2fcd1162fbac75c19bb29c95";
  };

  propagatedBuildInputs = [
    python-dateutil
  ];

  doCheck = true;

  meta = with lib; {
    description = "A library for parsing ISO 8601 strings";
    homepage = https://bitbucket.org/nielsenb/aniso8601;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
