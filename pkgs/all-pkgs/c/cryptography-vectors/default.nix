{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.0.2";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "512f1e699dfbb41376e938e6dc6d7f1f40b9578f873438f002e2e5212e13717b";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
