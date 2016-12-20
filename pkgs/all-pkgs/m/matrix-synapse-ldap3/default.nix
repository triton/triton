{ stdenv
, buildPythonPackage
, fetchFromGitHub

, ldap3
, service-identity
, twisted
}:

let
  version = "0.1.0";
in
buildPythonPackage {
  name = "matrix-synapse-ldap3-${version}";
  
  src = fetchFromGitHub {
    version = 2;
    owner = "matrix-org";
    repo = "matrix-synapse-ldap3";
    rev = "v${version}";
    sha256 = "00494986c7ed77149233c9cf134a3e8fefe4fcfc2864acbde1801517c4b76170";
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
