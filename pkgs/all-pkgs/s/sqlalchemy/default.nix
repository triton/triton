{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "sqlalchemy-${version}";
  version = "1.1.0";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "3b06994fafb472b5db3fdb73284f8fdc412016d481516fa93b03219e52601c2c";
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
