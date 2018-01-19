{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.2.1";
in
buildPythonPackage rec {
  name = "sqlalchemy-${version}";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "9ede7070d6fd18f28058be88296ed67893e2637465516d6a596cd9afea97b154";
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
