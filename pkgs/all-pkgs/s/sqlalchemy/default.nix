{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "sqlalchemy-${version}";
  version = "1.1.2";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "1692c35bc0f7026d20cabd43b0f6f265e855129f44eb4574fea361e3c5cc89a5";
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
