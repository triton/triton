{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyasn1
}:

let
  version = "2.5";
in
buildPythonPackage {
  name = "ldap3-${version}";

  src = fetchPyPi {
    package = "ldap3";
    inherit version;
    sha256 = "55078bbc981f715a8867b4c040402627fdfccf5664e0277a621416559748e384";
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
