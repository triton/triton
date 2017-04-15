{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.10.0";
in
buildPythonPackage rec {
  name = "fonttools-${version}";

  src = fetchPyPi {
    package = "fonttools";
    inherit version;
    type = ".zip";
    sha256 = "d165f83078a8f1bb9f466b12cee1ff402f39ebf143970762ef34abdb13fd4255";
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
