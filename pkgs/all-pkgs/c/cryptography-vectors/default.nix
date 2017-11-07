{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.1.3";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "2de4957fdfd567d69e179d6e9ecf54a085387c953e20abf97a35a5c313aa3053";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
