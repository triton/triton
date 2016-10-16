{ stdenv
, buildPythonPackage
, fetchPyPi

, cryptography
, six
}:

let
  version = "16.2.0";
in
buildPythonPackage {
  name = "pyOpenSSL-${version}";

  src = fetchPyPi {
    package = "pyOpenSSL";
    inherit version;
    sha256 = "7779a3bbb74e79db234af6a08775568c6769b5821faecf6e2f4143edb227516e";
  };

  propagatedBuildInputs = [
    cryptography
    six
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
