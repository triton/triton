{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cyrus-sasl
, openldap
}:

let
  version = "2.4.39";
in
buildPythonPackage {
  name = "python-ldap-${version}";

  src = fetchPyPi {
    package = "python-ldap";
    inherit version;
    sha256 = "3fb75108d27e8091de80dffa2ba3bf45c7a3bdc357e2959006aed52fa58bb2f3";
  };

  NIX_CFLAGS_COMPILE = "-I${cyrus-sasl}/include/sasl";

  buildInputs = [
    cyrus-sasl
    openldap
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
