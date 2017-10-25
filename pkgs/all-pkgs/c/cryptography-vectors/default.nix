{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.1.2";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "1d3829bdb7b7822cee85a829fe2e0d2455d69e242186705ef1a9d4d1ab6337df";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
