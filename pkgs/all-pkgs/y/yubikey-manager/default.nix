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
  version = "1.0.1";
in
buildPythonPackage {
  name = "yubikey-manager-${version}";

  src = fetchPyPi {
    package = "yubikey-manager";
    inherit version;
    sha256 = "1f915d8899dbcf85b6b9879f5664953ce1edcd5a503a00d03b9c6298900bfc44";
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
