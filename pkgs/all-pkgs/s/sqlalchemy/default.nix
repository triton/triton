{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.2.6";
in
buildPythonPackage rec {
  name = "sqlalchemy-${version}";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "7cb00cc9b9f92ef8b4391c8a2051f81eeafefe32d63c6b395fd51401e9a39edb";
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
