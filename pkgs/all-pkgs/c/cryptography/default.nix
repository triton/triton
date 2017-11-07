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

  version = "2.1.3";
in
buildPythonPackage {
  name = "cryptography-${version}";

  src = fetchPyPi {
    package = "cryptography";
    inherit version;
    sha256 = "68a26c353627163d74ee769d4749f2ee243866e9dac43c93bb33ebd8fbed1199";
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
