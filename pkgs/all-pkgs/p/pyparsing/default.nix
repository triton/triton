{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "pyparsing-${version}";
  version = "2.1.6";

  src = fetchPyPi {
    package = "pyparsing";
    inherit version;
    sha256 = "3bbdeb6ba83077136cebf642fb0ac526a4230f72944e7f6a240df2fdd83c6e66";
  };

  doCheck = true;

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
