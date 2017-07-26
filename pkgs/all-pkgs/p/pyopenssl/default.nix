{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cryptography
, six
}:

let
  version = "17.2.0";
in
buildPythonPackage {
  name = "pyOpenSSL-${version}";

  src = fetchPyPi {
    package = "pyOpenSSL";
    inherit version;
    sha256 = "5d617ce36b07c51f330aa63b83bf7f25c40a0e95958876d54d1982f8c91b4834";
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
