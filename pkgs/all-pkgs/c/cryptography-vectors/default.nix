{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.6";
in
buildPythonPackage {
  name = "cryptography-vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "bad285163b8fde85a46cf3649fb7a3d6d3f6bd279cd04ec07b02ef46ef8e0d74";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
