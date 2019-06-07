{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, pythonOlder

, asn1crypto
, cffi
, enum34
, idna
, ipaddress
, openssl
, packaging
, six
}:

let
  inherit (lib)
    optionals;

  version = "2.7";
in
buildPythonPackage {
  name = "cryptography-${version}";

  src = fetchPyPi {
    package = "cryptography";
    inherit version;
    sha256 = "e6347742ac8f35ded4a46ff835c60e68c22a536a8ae5c4422966d06946b6d4c6";
  };

  buildInputs = [
    openssl
    six
  ];

  propagatedBuildInputs = [
    asn1crypto
    cffi
    idna
    ipaddress
    packaging
  ] ++ optionals (pythonOlder "3.4") [
    enum34
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
