{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.1.6";
in
buildPythonPackage rec {
  name = "sqlalchemy-${version}";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "815924e3218d878ddd195d2f9f5bf3d2bb39fabaddb1ea27dace6ac27d9865e4";
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
