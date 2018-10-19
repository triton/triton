{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "7.0";
in
buildPythonPackage {
  name = "click-${version}";

  src = fetchPyPi {
    package = "Click";
    inherit version;
    sha256 = "5b94b49521f6456670fdb30cd82a4eca9412788a93fa6dd6df72c94d5a8ff2d7";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
