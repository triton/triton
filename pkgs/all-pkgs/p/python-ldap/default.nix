{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cyrus-sasl
, openldap
}:

let
  version = "2.4.40";
in
buildPythonPackage {
  name = "python-ldap-${version}";

  src = fetchPyPi {
    package = "python-ldap";
    inherit version;
    sha256 = "202f2f4aeeed2333d4095e8122d066e502e9a64de30cb09ffae16d18c71053f4";
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
