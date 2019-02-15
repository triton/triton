{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.1.0";
in
buildPythonPackage {
  name = "h2-${version}";

  src = fetchPyPi {
    package = "h2";
    inherit version;
    sha256 = "fd07e865a3272ac6ef195d8904de92dc7b38dc28297ec39cfa22716b6d62e6eb";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
