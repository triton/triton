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

  version = "1.5";
in
buildPythonPackage {
  name = "cryptography-${version}";

  src = fetchPyPi {
    package = "cryptography";
    inherit version;
    sha256 = "52f47ec9a57676043f88e3ca133638790b6b71e56e8890d9d7f3ae4fcd75fa24";
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
