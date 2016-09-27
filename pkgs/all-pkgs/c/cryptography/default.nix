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

  version = "1.5.2";
in
buildPythonPackage {
  name = "cryptography-${version}";

  src = fetchPyPi {
    package = "cryptography";
    inherit version;
    sha256 = "eb8875736734e8e870b09be43b17f40472dc189b1c422a952fa8580768204832";
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
