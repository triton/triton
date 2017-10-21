{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.10.11";
in
buildPythonPackage {
  name = "wrapt-${version}";

  src = fetchPyPi {
    package = "wrapt";
    inherit version;
    sha256 = "d4d560d479f2c21e1b5443bbd15fe7ec4b37fe7e53d335d3b9b0a7b1226fe3c6";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
