{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "6.7";
in
buildPythonPackage {
  name = "click-${version}";

  src = fetchPyPi {
    package = "click";
    inherit version;
    sha256 = "f15516df478d5a56180fbf80e68f206010e6d160fc39fa508b65e035fd75130b";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
