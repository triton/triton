{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.1.8";
in
buildPythonPackage rec {
  name = "pyparsing-${version}";

  src = fetchPyPi {
    package = "pyparsing";
    inherit version;
    sha256 = "03a4869b9f3493807ee1f1cb405e6d576a1a2ca4d81a982677c0c1ad6177c56b";
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
