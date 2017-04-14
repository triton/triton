{ stdenv
, buildPythonPackage
, fetchFromGitHub

, ldap3
, service-identity
, twisted
}:

let
  version = "0.1.2";
in
buildPythonPackage {
  name = "matrix-synapse-ldap3-${version}";
  
  src = fetchFromGitHub {
    version = 2;
    owner = "matrix-org";
    repo = "matrix-synapse-ldap3";
    rev = "v${version}";
    sha256 = "b0b4d93d6b651f312cb93929f88af9fef936c900f88b1cde0a7c1dcb1151fb68";
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
