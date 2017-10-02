{ stdenv
, buildPythonPackage
, fetchPyPi

, ldap3
, service-identity
, twisted
}:

let
  version = "0.1.3";
in
buildPythonPackage {
  name = "matrix-synapse-ldap3-${version}";
  
  src = fetchPyPi {
    package = "matrix-synapse-ldap3";
    inherit version;
    sha256 = "f6cd04a901ef136cc45b50e68fadf5cf8cb947ee754166f66c4b81e8930f0d28";
  };

  propagatedBuildInputs = [
    ldap3
    service-identity
    twisted
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
