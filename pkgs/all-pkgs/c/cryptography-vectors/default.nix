{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.0.3";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "beb831aa73663a224f4d7520483ed02da544533bb03b26ec07a5f9a0dd0941e1";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
