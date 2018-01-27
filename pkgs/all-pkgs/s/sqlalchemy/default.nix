{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.2.2";
in
buildPythonPackage rec {
  name = "sqlalchemy-${version}";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "64b4720f0a8e033db0154d3824f5bf677cf2797e11d44743cf0aebd2a0499d9d";
  };

  meta = with lib; {
    description = "A Python SQL toolkit and Object Relational Mapper";
    homepage = http://www.sqlalchemy.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
