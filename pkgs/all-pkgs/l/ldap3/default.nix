{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyasn1
}:

let
  version = "2.4.1";
in
buildPythonPackage {
  name = "ldap3-${version}";

  src = fetchPyPi {
    package = "ldap3";
    inherit version;
    sha256 = "e8fe0d55a8cecb725748c831ffac2873df94c05b2d7eb867ea167c0500bbc6a8";
  };

  buildInputs = [
    pyasn1
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
