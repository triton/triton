{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cryptography
, six
}:

let
  version = "18.0.0";
in
buildPythonPackage {
  name = "pyOpenSSL-${version}";

  src = fetchPyPi {
    package = "pyOpenSSL";
    inherit version;
    sha256 = "6488f1423b00f73b7ad5167885312bb0ce410d3312eb212393795b53c8caa580";
  };

  propagatedBuildInputs = [
    cryptography
    six
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
