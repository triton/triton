{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, secretstorage
, setuptools-scm
}:

let
  version = "10.4.0";
in
buildPythonPackage {
  name = "keyring-${version}";

  src = fetchPyPi {
    package = "keyring";
    inherit version;
    sha256 = "901a3f4ed0dfba473060281b58fd3b649ce70f59cb34a9cf6cb5551218283b26";
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
