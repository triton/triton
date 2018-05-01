{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, swig

, openssl
, typing
}:

let
  version = "0.30.1";
in
buildPythonPackage {
  name = "M2Crypto-${version}";

  src = fetchPyPi {
    package = "M2Crypto";
    inherit version;
    sha256 = "a1b2751cdadc6afac3df8a5799676b7b7c67a6ad144bb62d38563062e7cd3fc6";
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
