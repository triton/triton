{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.8";
in
buildPythonPackage {
  name = "spake2-${version}";

  src = fetchPyPi {
    package = "spake2";
    inherit version;
    sha256 = "c17a614b29ee4126206e22181f70a406c618d3c6c62ca6d6779bce95e9c926f4";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
