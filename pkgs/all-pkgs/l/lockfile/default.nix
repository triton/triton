{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.12.2";
in
buildPythonPackage {
  name = "lockfile-${version}";

  src = fetchPyPi {
    package = "lockfile";
    inherit version;
    sha256 = "6007daf714d0cd5524bbe436e2d42b3c20e68da66289559341e48d2cd6d25811";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
