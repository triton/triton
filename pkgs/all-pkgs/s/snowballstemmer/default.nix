{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.2.1";
in
buildPythonPackage {
  name = "snowballstemmer-${version}";

  src = fetchPyPi {
    package = "snowballstemmer";
    inherit version;
    sha256 = "919f26a68b2c17a7634da993d91339e288964f93c274f1343e3bbbe2096e1128";
  };
  
  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
