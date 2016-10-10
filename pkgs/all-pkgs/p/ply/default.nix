{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.9";
in
buildPythonPackage {
  name = "ply-${version}";

  src = fetchPyPi {
    package = "ply";
    inherit version;
    sha256 = "0d7e2940b9c57151392fceaa62b0865c45e06ce1e36687fd8d03f011a907f43e";
  };

  meta = with stdenv.lib; {
    homepage = http://www.dabeaz.com/ply/;
    description = "Python implementation of the lex & yacc parsing tools";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
