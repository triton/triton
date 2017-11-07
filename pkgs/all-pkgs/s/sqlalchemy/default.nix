{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.1.15";
in
buildPythonPackage rec {
  name = "sqlalchemy-${version}";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "8b79a5ed91cdcb5abe97b0045664c55c140aec09e5dd5c01303e23de5fe7a95a";
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
