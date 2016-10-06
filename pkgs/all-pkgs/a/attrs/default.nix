{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "attrs-${version}";
  version = "16.2.0";

  src = fetchPyPi {
    package = "attrs";
    inherit version;
    sha256 = "136f2ec0f94ec77ff2990830feee965d608cab1e8922370e3abdded383d52001";
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
