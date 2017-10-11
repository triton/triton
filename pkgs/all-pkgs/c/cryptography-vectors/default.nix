{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.1";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "d36f60ed7fd2966118527639ac9aa0b84b9d5ba15ca471089ed6bc1af9ece8ff";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
