{ stdenv
, buildPythonPackage
, fetchPyPi

, cryptography
, six
}:

let
  version = "16.1.0";
in
buildPythonPackage {
  name = "pyOpenSSL-${version}";

  src = fetchPyPi {
    package = "pyOpenSSL";
    inherit version;
    sha256 = "88f7ada2a71daf2c78a4f139b19d57551b4c8be01f53a1cb5c86c2f3bf01355f";
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
