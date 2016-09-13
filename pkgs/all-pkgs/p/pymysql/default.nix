{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.7.9";
in
buildPythonPackage rec {
  name = "pymysql-${version}";

  src = fetchPyPi {
    package = "PyMySQL";
    inherit version;
    sha256 = "2331f82b7b85d407c8d9d7a8d7901a6abbeb420533e5d5d64ded5009b5c6dcc3";
  };

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Pure Python MySQL Driver";
    homepage = https://github.com/PyMySQL/PyMySQL/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
