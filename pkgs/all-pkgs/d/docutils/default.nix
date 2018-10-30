{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.14";
in
buildPythonPackage {
  name = "docutils-${version}";

  src = fetchPyPi {
    package = "docutils";
    inherit version;
    sha256 = "51e64ef2ebfb29cae1faa133b3710143496eca21c530f3f71424d77687764274";
  };
  
  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
