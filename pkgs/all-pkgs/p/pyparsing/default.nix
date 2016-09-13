{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.1.9";
in
buildPythonPackage rec {
  name = "pyparsing-${version}";

  src = fetchPyPi {
    package = "pyparsing";
    inherit version;
    sha256 = "93326f5490bcfe7069806ff342692e75f72529cfa82f20683b5fceeb5d4a7fc2";
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
