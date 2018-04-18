{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, swig

, openssl
, typing
}:

let
  version = "0.29.0";
in
buildPythonPackage {
  name = "M2Crypto-${version}";

  src = fetchPyPi {
    package = "M2Crypto";
    inherit version;
    sha256 = "a0fea2c5ab913e42864d1ccbaee5878c23886368b606e923609fda4ce37d26c0";
  };

  nativeBuildInputs = [
    swig
  ];

  buildInputs = [
    openssl
  ];

  propagatedBuildInputs = [
    typing
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
