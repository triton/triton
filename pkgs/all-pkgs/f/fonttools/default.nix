{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.3.1";
in
buildPythonPackage rec {
  name = "fonttools-${version}";

  src = fetchPyPi {
    package = "fonttools";
    inherit version;
    type = ".zip";
    sha256 = "30c9f68d55a1b648e4d5b137fb8f137ac6c80ebaae351a8eaaaa84a2823407d3";
  };

  meta = with stdenv.lib; {
    description = "Library for manipulating fonts";
    homepage = https://github.com/behdad/fonttools;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
