{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "sqlalchemy-${version}";
  version = "1.0.13";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "e755fd23b8bd574163d392ae85f41f6cd32eca8fe5bd7b5692de77265bb220cf";
  };

  meta = with stdenv.lib; {
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
