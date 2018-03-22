{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.2.1";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "be7cf2e4de057f2a5307d9600177014daefd58a96de9cb9f437c26753fd462fe";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
