{ stdenv
, buildPythonPackage
, fetchurl
}:

buildPythonPackage rec {
  name = "PyMySQL-0.7.2";

  src = fetchurl {
    url = "mirror://pypi/P/PyMySQL/${name}.tar.gz";
    sha256 = "bd7acb4990dbf097fae3417641f93e25c690e01ed25c3ed32ea638d6c3ac04ba";
  };

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
