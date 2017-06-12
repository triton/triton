{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.9";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "bbf767727ad1b9d4cb684fb2b36db4cc78bd420fa6999e7e6ca1aab8c30d78f3";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
