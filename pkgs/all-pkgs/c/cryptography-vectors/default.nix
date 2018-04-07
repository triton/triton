{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.2.2";
in
buildPythonPackage {
  name = "cryptography-vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "28b52c84bae3a564ce51bfb0753cbe360218bd648c64efa2808c886c18505688";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
