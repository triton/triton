{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, unzip
}:

let
  version = "3.43.2";
in
buildPythonPackage rec {
  name = "fonttools-${version}";

  src = fetchPyPi {
    package = "fonttools";
    inherit version;
    type = ".zip";
    sha256 = "3a804bca2434776b6d9e39b54738d2232017b937ba1f86a5129ab756ad804263";
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
