{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "attrs-${version}";
  version = "15.2.0";

  src = fetchPyPi {
    package = "attrs";
    inherit version;
    sha256 = "9f895d2ecefa0be054e29375769f1d0ee88e93ce820088cf5c49390529bf7ee7";
  };

  meta = with stdenv.lib; {
    description = "Attributes without boilerplate";
    homepage = https://github.com/hynek/attrs;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
