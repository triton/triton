{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.4.6";
in
buildPythonPackage {
  name = "pycryptodomex-${version}";

  src = fetchPyPi {
    package = "pycryptodomex";
    inherit version;
    sha256 = "cc43b0e76f76f15da149c27ae3a4ceaf782a7a4c26c5b024eb30dab19156d15e";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
