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
  version = "2.0.0";
in
buildPythonPackage {
  name = "yubikey-manager-${version}";

  src = fetchPyPi {
    package = "yubikey-manager";
    inherit version;
    sha256 = "e95b4c4e956e105780e59ca2e4f159b4e974da38cdc810d4157e8d979ebf66f4";
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
