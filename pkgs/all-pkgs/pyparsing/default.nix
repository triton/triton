{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "pyparsing-${version}";
  version = "2.1.4";

  src = fetchPyPi {
    package = "pyparsing";
    inherit version;
    sha256 = "a9234dea79b50d49b92a994132cd1c84e873f3936db94977a66f0a4159b1797c";
  };

  meta = with stdenv.lib; {
    description = "Python parsing module";
    homepage = http://pyparsing.wikispaces.com/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
