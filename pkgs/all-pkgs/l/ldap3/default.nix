{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyasn1
}:

let
  version = "2.2.4";
in
buildPythonPackage {
  name = "ldap3-${version}";

  src = fetchPyPi {
    package = "ldap3";
    inherit version;
    sha256 = "40c4d670e8e0f046ba2e29e3d9592b810c22094dcce83240a1c1695fb3602604";
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
