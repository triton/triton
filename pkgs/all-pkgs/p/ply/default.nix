{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.10";
in
buildPythonPackage {
  name = "ply-${version}";

  src = fetchPyPi {
    package = "ply";
    inherit version;
    sha256 = "96e94af7dd7031d8d6dd6e2a8e0de593b511c211a86e28a9c9621c275ac8bacb";
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
