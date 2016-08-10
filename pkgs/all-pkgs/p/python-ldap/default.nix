{ stdenv
, buildPythonPackage
, fetchPyPi

, cyrus-sasl
, openldap
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "2.4.25";
in
buildPythonPackage {
  name = "python-ldap-${version}";

  src = fetchPyPi {
    package = "python-ldap";
    inherit version;
    sha256 = "62d00dbc86f3f9b21beacd9b826e8f9895f900637a60a6d4e7ab59a1cdc64e56";
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
