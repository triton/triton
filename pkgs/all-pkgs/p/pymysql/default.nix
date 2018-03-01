{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.7.11";
in
buildPythonPackage rec {
  name = "pymysql-${version}";

  src = fetchPyPi {
    package = "PyMySQL";
    inherit version;
    sha256 = "56e3f5bcef6501012233620b54f6a7b8a34edc5751e85e4e3da9a0d808df5f68";
  };

  meta = with lib; {
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
