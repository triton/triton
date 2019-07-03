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
  version = "3.0.0";
in
buildPythonPackage {
  name = "yubikey-manager-${version}";

  src = fetchPyPi {
    package = "yubikey-manager";
    inherit version;
    sha256 = "815746ad93780884a0ceb8cb4569a902f2317511b3a41ceead8f9be0a9b1f220";
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
