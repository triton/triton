{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, unzip
}:

let
  version = "0.4.0";
in
buildPythonPackage rec {
  name = "colorama-${version}";

  src = fetchPyPi {
    package = "colorama";
    inherit version;
    type = ".zip";
    sha256 = "c9b54bebe91a6a803e0772c8561d53f2926bfeb17cd141fbabcb08424086595c";
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
