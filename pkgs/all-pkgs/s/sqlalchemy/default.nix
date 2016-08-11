{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "sqlalchemy-${version}";
  version = "1.0.14";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "da4d1a39c1e99c7fecc2aaa3a050094b6aa7134de7d89f77e6216e7abd1705b3";
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
