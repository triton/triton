{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.3.1";
in
buildPythonPackage {
  name = "cryptography-vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "bf4d9b61dce69c49e830950aa36fad194706463b0b6dfe81425b9e0bc6644d46";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
