{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, click
, cryptography
, fido2
, pyscard
, pyopenssl
, pyusb
}:

let
  version = "2.1.0";
in
buildPythonPackage {
  name = "yubikey-manager-${version}";

  src = fetchPyPi {
    package = "yubikey-manager";
    inherit version;
    sha256 = "d59d5cd9b5b040077ef7741250476d8583bf961519b6576af163022315ab3a87";
  };

  propagatedBuildInputs = [
    click
    cryptography
    fido2
    pyscard
    pyopenssl
    pyusb
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
