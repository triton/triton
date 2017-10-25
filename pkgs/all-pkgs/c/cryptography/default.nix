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

  version = "2.1.2";
in
buildPythonPackage {
  name = "cryptography-${version}";

  src = fetchPyPi {
    package = "cryptography";
    inherit version;
    sha256 = "d7f348e4f5df146a0e75998544bab6d42313cf19a81a6e49990ab7b27cc9c73b";
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
