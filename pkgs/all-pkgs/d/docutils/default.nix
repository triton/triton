{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.12";
in
buildPythonPackage {
  name = "docutils-${version}";

  src = fetchPyPi {
    package = "docutils";
    inherit version;
    sha256 = "c7db717810ab6965f66c8cf0398a98c9d8df982da39b4cd7f162911eb89596fa";
  };
  
  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
