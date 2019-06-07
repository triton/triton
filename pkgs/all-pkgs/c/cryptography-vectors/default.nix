{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.7";
in
buildPythonPackage {
  name = "cryptography-vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "f12dfb9bd669a68004074cb5b26df6e93ed1a95ebd1a999dff0a840212ff68bc";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
