{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.4.7";
in
buildPythonPackage {
  name = "pycryptodomex-${version}";

  src = fetchPyPi {
    package = "pycryptodomex";
    inherit version;
    sha256 = "52aa2e540d06d63636e4b5356957c520611e28a88386bad4d18980e4b00e0b5a";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
