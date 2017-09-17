{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cryptography
, six
}:

let
  version = "17.3.0";
in
buildPythonPackage {
  name = "pyOpenSSL-${version}";

  src = fetchPyPi {
    package = "pyOpenSSL";
    inherit version;
    sha256 = "29630b9064a82e04d8242ea01d7c93d70ec320f5e3ed48e95fcabc6b1d0f6c76";
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
