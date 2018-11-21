{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.7.12";
in
buildPythonPackage {
  name = "alabaster-${version}";

  src = fetchPyPi {
    package = "alabaster";
    inherit version;
    sha256 = "a661d72d58e6ea8a57f7a86e37d86716863ee5e92788398526d58b26a4e4dc02";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
