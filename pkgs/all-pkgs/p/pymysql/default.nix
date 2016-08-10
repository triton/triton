{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "pymysql-${version}";
  version = "0.7.2";

  src = fetchPyPi {
    package = "PyMySQL";
    inherit version;
    sha256 = "bd7acb4990dbf097fae3417641f93e25c690e01ed25c3ed32ea638d6c3ac04ba";
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
