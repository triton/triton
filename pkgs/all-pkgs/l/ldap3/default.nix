{ stdenv
, buildPythonPackage
, fetchPyPi

, pyasn1
}:

let
  version = "2.1.0";
in
buildPythonPackage {
  name = "ldap3-${version}";
  
  src = fetchPyPi {
    package = "ldap3";
    inherit version;
    sha256 = "8a9b0331d9405884ac273106ded1a7d9ad5ba3e309c4bad25bae7dc5774cc809";
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
