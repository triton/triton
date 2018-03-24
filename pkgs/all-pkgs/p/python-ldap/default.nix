{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cyrus-sasl
, openldap
}:

let
  version = "3.0.0";
in
buildPythonPackage {
  name = "python-ldap-${version}";

  src = fetchPyPi {
    package = "python-ldap";
    inherit version;
    sha256 = "86746b912a2cd37a54b06c694f021b0c8556d4caeab75ef50435ada152e2fbe1";
  };

  NIX_CFLAGS_COMPILE = "-I${cyrus-sasl}/include/sasl";

  buildInputs = [
    cyrus-sasl
    openldap
  ];

  meta = with lib; {
    description = "Modules for implementing LDAP clients";
    homepage = https://www.python-ldap.org;
    license = licenses.psf-2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
