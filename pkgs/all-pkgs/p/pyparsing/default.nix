{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.1.10";
in
buildPythonPackage rec {
  name = "pyparsing-${version}";

  src = fetchPyPi {
    package = "pyparsing";
    inherit version;
    sha256 = "811c3e7b0031021137fc83e051795025fcb98674d07eb8fe922ba4de53d39188";
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
