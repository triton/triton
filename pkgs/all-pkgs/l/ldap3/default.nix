{ stdenv
, buildPythonPackage
, fetchPyPi

, pyasn1
}:

let
  version = "1.4.0";
in
buildPythonPackage {
  name = "ldap3-${version}";
  
  src = fetchPyPi {
    package = "ldap3";
    inherit version;
    sha256 = "f69cb30894423b31b44206fa0548f2bf38cb5afc527f6c1a6e90f6c9327ef901";
  };

  buildInputs = [
    pyasn1
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
