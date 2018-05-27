{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, secretstorage
, setuptools-scm
}:

let
  version = "12.2.1";
in
buildPythonPackage {
  name = "keyring-${version}";

  src = fetchPyPi {
    package = "keyring";
    inherit version;
    sha256 = "4498eaa2e32fc69a8b36749116b670c379d36a1a9ad4ab107df1e19c8a120ffe";
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
