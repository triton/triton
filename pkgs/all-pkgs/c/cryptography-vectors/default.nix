{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.8.2";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "00daa04c9870345f56605d91d7d4897bc1b16f6fff7c74cb602b08ef16c0fb43";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
