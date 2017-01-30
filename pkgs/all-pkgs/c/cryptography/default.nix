{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
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

  version = "1.7.2";
in
buildPythonPackage {
  name = "cryptography-${version}";

  src = fetchPyPi {
    package = "cryptography";
    inherit version;
    sha256 = "878cb68b3da3d493ffd68f36db11c29deee623671d3287c3f8d685117ffda9a9";
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

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
