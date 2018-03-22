{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.6";
in
buildPythonPackage {
  name = "idna-${version}";

  src = fetchPyPi {
    package = "idna";
    inherit version;
    sha256 = "2c6a5de3089009e3da7c5dde64a141dbc8551d5b7f6cf4ed7c2568d0cc520a8f";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
