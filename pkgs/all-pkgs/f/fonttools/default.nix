{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, unzip
}:

let
  version = "3.19.0";
in
buildPythonPackage rec {
  name = "fonttools-${version}";

  src = fetchPyPi {
    package = "fonttools";
    inherit version;
    type = ".zip";
    sha256 = "8d1dcb1ff3665b69e52d020590e20c460445b7d80b5cb573832cf97ec97c74af";
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
