{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, unzip
}:

let
  version = "0.4.1";
in
buildPythonPackage rec {
  name = "colorama-${version}";

  src = fetchPyPi {
    package = "colorama";
    inherit version;
    sha256 = "05eed71e2e327246ad6b38c540c4a3117230b19679b875190486ddd2d721422d";
  };

  nativeBuildInputs = [
    unzip
  ];

  meta = with lib; {
    description = "Cross-platform colored terminal text";
    homepage = https://github.com/tartley/colorama;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
