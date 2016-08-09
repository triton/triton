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

  version = "1.4";
in
buildPythonPackage {
  name = "cryptography-${version}";

  src = fetchPyPi {
    package = "cryptography";
    inherit version;
    sha256 = "bb149540ed90c4b2171bf694fe6991d6331bc149ae623c8ff419324f4222d128";
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
