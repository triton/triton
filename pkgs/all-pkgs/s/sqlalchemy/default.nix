{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.1.13";
in
buildPythonPackage rec {
  name = "sqlalchemy-${version}";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "2a98ac87b30eaa2bee1f1044848b9590e476e7f93d033c6542e60b993a5cf898";
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
