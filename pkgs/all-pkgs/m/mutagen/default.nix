{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.40.0";
in
buildPythonPackage rec {
  name = "mutagen-${version}";

  src = fetchPyPi {
    package = "mutagen";
    inherit version;
    sha256 = "b2a2c2ce87863af12ed7896f341419cd051a3c72c3c6733db9e83060dcadee5e";
  };

  doCheck = false;

  meta = with lib; {
    description = "Python multimedia tagging library";
    homepage = https://github.com/quodlibet/mutagen;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
