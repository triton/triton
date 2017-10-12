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

  version = "2.1.1";
in
buildPythonPackage {
  name = "cryptography-${version}";

  src = fetchPyPi {
    package = "cryptography";
    inherit version;
    sha256 = "2699ed21e1f73dd1bdb7b0b22a517295de07809d535b23e200dd22166037fe6f";
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
