{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "sqlalchemy-${version}";
  version = "1.0.15";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "586f5ccf068211795a89ed22d196c5cc3006b6be00261bcac6f584c0b8e0845a";
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
