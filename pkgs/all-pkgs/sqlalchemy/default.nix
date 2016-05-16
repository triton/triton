{ stdenv
, buildPythonPackage
, fetchPyPi

, mysql
, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
in

buildPythonPackage rec {
  name = "sqlalchemy-${version}";
  version = "1.0.12";

  src = fetchPyPi {
    package = "SQLAlchemy";
    inherit version;
    sha256 = "6679e20eae780b67ba136a4a76f83bb264debaac2542beefe02069d0206518d1";
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
