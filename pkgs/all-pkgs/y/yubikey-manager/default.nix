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
  version = "0.7.1";
in
buildPythonPackage {
  name = "yubikey-manager-${version}";

  src = fetchPyPi {
    package = "yubikey-manager";
    inherit version;
    sha256 = "177bbf953b8557b8de68bacbbdfc56764e93733f337b2327e322cfc4ed4f7d18";
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
