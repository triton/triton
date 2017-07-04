{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cryptography
, six
}:

let
  version = "17.1.0";
in
buildPythonPackage {
  name = "pyOpenSSL-${version}";

  src = fetchPyPi {
    package = "pyOpenSSL";
    inherit version;
    sha256 = "5a20a51d35104cd234d056861ace3e7a335aaf1f47fc96726c9e20ac1dc49563";
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
