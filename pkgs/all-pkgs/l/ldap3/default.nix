{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyasn1
}:

let
  version = "2.5.1";
in
buildPythonPackage {
  name = "ldap3-${version}";

  src = fetchPyPi {
    package = "ldap3";
    inherit version;
    sha256 = "cc09951809678cfb693a13a6011dd2d48ada60a52bd80cb4bd7dcc55ee7c02fd";
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
