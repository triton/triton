{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, unzip
}:

let
  version = "3.26.0";
in
buildPythonPackage rec {
  name = "fonttools-${version}";

  src = fetchPyPi {
    package = "fonttools";
    inherit version;
    type = ".zip";
    sha256 = "a5c35273ce972e0dd26efba9f84e0488053ab0ebcb29c4de37eb3a3669254a23";
  };

  nativeBuildInputs = [
    unzip
  ];

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
