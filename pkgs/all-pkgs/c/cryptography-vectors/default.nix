{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.5";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "ad19a2b98a475785c3b2ec8a8c9c974e0c48d00db0c23e79d776a2c489ad812d";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
