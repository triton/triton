{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, click
, cryptography
, pyscard
, pyopenssl
, pyusb
}:

let
  version = "0.4.6";
in
buildPythonPackage {
  name = "yubikey-manager-${version}";

  src = fetchPyPi {
    package = "yubikey-manager";
    inherit version;
    sha256 = "6f9aae731e1c71ea65bea48911aa33a29b284afbabe9430f84e07a27cfcfcbeb";
  };

  propagatedBuildInputs = [
    click
    cryptography
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
