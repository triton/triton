{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cryptography
, six
}:

let
  version = "19.0.0";
in
buildPythonPackage {
  name = "pyOpenSSL-${version}";

  src = fetchPyPi {
    package = "pyOpenSSL";
    inherit version;
    sha256 = "aeca66338f6de19d1aa46ed634c3b9ae519a64b458f8468aec688e7e3c20f200";
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
