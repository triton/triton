{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, unzip
}:

let
  version = "3.24.2";
in
buildPythonPackage rec {
  name = "fonttools-${version}";

  src = fetchPyPi {
    package = "fonttools";
    inherit version;
    type = ".zip";
    sha256 = "7b96cc898d4147fed38377a4b9696573b3ba6ef13cba24b9e4dd73e97791af81";
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
