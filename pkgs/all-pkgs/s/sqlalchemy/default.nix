{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.2.7";
in
buildPythonPackage rec {
  name = "sqlalchemy-${version}";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "d6cda03b0187d6ed796ff70e87c9a7dce2c2c9650a7bc3c022cd331416853c31";
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
