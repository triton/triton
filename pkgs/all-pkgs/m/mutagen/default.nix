{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.38";
in
buildPythonPackage rec {
  name = "mutagen-${version}";

  src = fetchPyPi {
    package = "mutagen";
    inherit version;
    sha256 = "23990f70ae678c7b8df3fd59e2adbefa5fe392c36da8c71d2254b21c6cd78766";
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
