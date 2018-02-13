{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.4.9";
in
buildPythonPackage {
  name = "pycryptodomex-${version}";

  src = fetchPyPi {
    package = "pycryptodomex";
    inherit version;
    sha256 = "d078b67be76ccafa8b7cc391e87151b80b0ef9bfbeee8a95d286e522cc7537f7";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
