{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.3";
in
buildPythonPackage {
  name = "cryptography-vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "356a2ded84ae379e556515eec9b68dd74957651a38465d10605bb9fbae280f15";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
