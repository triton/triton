{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.2.4";
in
buildPythonPackage rec {
  name = "sqlalchemy-${version}";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "6997507af46b10630e13b605ac278b78885fd683d038896dbee0e7ec41d809d2";
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
