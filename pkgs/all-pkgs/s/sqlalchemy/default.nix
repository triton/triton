{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.2.0";
in
buildPythonPackage rec {
  name = "sqlalchemy-${version}";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "7dda3e0b1b12215e3bb05368d1abbf7d747112a43738e0a4e6deb466b83fd88e";
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
