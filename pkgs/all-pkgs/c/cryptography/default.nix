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

  version = "2.4.2";
in
buildPythonPackage {
  name = "cryptography-${version}";

  src = fetchPyPi {
    package = "cryptography";
    inherit version;
    sha256 = "05a6052c6a9f17ff78ba78f8e6eb1d777d25db3b763343a1ae89a7a8670386dd";
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
