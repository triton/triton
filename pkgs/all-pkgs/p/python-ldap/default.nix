{ stdenv
, buildPythonPackage
, fetchPyPi

, cyrus-sasl
, openldap
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "2.4.27";
in
buildPythonPackage {
  name = "python-ldap-${version}";

  src = fetchPyPi {
    package = "python-ldap";
    inherit version;
    sha256 = "6306a57a3c659ffda0003b386b1a23fdcee0b903a0ede0ce04c33ba78be64a2e";
  };

  NIX_CFLAGS_COMPILE = "-I${cyrus-sasl}/include/sasl";

  buildInputs = [
    cyrus-sasl
    openldap
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
