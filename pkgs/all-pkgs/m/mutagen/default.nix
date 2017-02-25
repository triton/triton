{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.37";
in
buildPythonPackage rec {
  name = "mutagen-${version}";

  src = fetchPyPi {
    package = "mutagen";
    inherit version;
    sha256 = "539553d3f1ffd890c74f64b819750aef0316933d162c09798c9e7eaf334ae760";
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
