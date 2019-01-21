{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, secretstorage
, setuptools-scm
}:

let
  version = "17.1.1";
in
buildPythonPackage {
  name = "keyring-${version}";

  src = fetchPyPi {
    package = "keyring";
    inherit version;
    sha256 = "8f683fa6c8886da58b28c7d8e3819b1a4bf193741888e33a6e00944b673a22cf";
  };

  propagatedBuildInputs = [
    secretstorage
    setuptools-scm
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
