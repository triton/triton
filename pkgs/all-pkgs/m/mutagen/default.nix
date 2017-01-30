{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.36.2";
in
buildPythonPackage rec {
  name = "mutagen-${version}";

  src = fetchPyPi {
    package = "mutagen";
    inherit version;
    sha256 = "86fe98e941ca305be8ee6bdc6bb0e4e9c473bf9fb69a838fe5bf2fc6124fbcc7";
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
