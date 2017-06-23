{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.7.2";
in
buildPythonPackage {
  name = "webob-${version}";

  src = fetchPyPi {
    package = "WebOb";
    inherit version;
    sha256 = "0dc8b30bdbf15d8fd1a967e30ece3357f2f468206354f69213e57b30a63f0039";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
