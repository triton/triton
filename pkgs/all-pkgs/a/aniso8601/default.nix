{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, python-dateutil
}:

let
  version = "1.2.1";
in
buildPythonPackage rec {
  name = "aniso8601-${version}";

  src = fetchPyPi {
    package = "aniso8601";
    inherit version;
    sha256 = "e7ba4f42d3aea75909c79b1f4c4614768b4f13fbb98fc658a7b6061ddb0be47c";
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
