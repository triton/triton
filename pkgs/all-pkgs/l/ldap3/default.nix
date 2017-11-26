{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyasn1
}:

let
  version = "2.4";
in
buildPythonPackage {
  name = "ldap3-${version}";

  src = fetchPyPi {
    package = "ldap3";
    inherit version;
    sha256 = "888015f849eb33852583bbaf382f61593b03491cdac6098fd5d4d0252e0e7e66";
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
