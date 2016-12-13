{ stdenv
, buildPythonPackage
, fetchPyPi
, pythonOlder

, cffi
, enum34
, idna
, ipaddress
, openssl
, pyasn1
, six
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "1.7";
in
buildPythonPackage {
  name = "cryptography-${version}";

  src = fetchPyPi {
    package = "cryptography";
    inherit version;
    sha256 = "404e5c0d1754e2a9bc85ef9e97420cc082fced024c914cc9ff1793f7b5f14931";
  };

  buildInputs = [
    openssl
    six
  ];

  propagatedBuildInputs = [
    cffi
    idna
    ipaddress
    pyasn1
  ] ++ optionals (pythonOlder "3.4") [
    enum34
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
