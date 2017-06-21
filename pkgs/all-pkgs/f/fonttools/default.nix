{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.13.1";
in
buildPythonPackage rec {
  name = "fonttools-${version}";

  src = fetchPyPi {
    package = "fonttools";
    inherit version;
    type = ".zip";
    sha256 = "ded1f9a6cdd6ed19a3df05ae40066d579ffded17369b976f9e701cf31b7b1f2d";
  };

  meta = with lib; {
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
