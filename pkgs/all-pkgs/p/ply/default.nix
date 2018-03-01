{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.11";
in
buildPythonPackage {
  name = "ply-${version}";

  src = fetchPyPi {
    package = "ply";
    inherit version;
    sha256 = "00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3";
  };

  meta = with lib; {
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
