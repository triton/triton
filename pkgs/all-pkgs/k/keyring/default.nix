{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, secretstorage
, setuptools-scm
}:

let
  version = "10.6.0";
in
buildPythonPackage {
  name = "keyring-${version}";

  src = fetchPyPi {
    package = "keyring";
    inherit version;
    sha256 = "69c2b69d66a0db1165c6875c1833c52f4dc62179959692b30c8c4a4b8390d895";
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
