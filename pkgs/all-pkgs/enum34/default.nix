{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "enum34-${version}";
  version = "1.1.5";

  src = fetchPyPi {
    package = "enum34";
    inherit version;
    sha256 = "35cf09a65db802269a76b7df60f548940575579a0e8a00ec45294995d28b0862";
  };

  meta = with stdenv.lib; {
    description = "Python 3.4 Enum backported to 2.4 through 3.3";
    homepage = https://bitbucket.org/stoneleaf/enum34;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
