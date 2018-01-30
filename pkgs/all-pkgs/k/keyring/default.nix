{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, secretstorage
, setuptools-scm
}:

let
  version = "11.0.0";
in
buildPythonPackage {
  name = "keyring-${version}";

  src = fetchPyPi {
    package = "keyring";
    inherit version;
    sha256 = "b4607520a7c97be96be4ddc00f4b9dac65f47a45af4b4cd13ed5a8879641d646";
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
