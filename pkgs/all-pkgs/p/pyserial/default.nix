{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.4";
in
buildPythonPackage {
  name = "pyserial-${version}";

  src = fetchPyPi {
    package = "pyserial";
    inherit version;
    sha256 = "6e2d401fdee0eab996cf734e67773a0143b932772ca8b42451440cfed942c627";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
