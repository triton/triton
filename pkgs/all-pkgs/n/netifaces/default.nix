{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.10.6";
in
buildPythonPackage {
  name = "netifaces-${version}";

  src = fetchPyPi {
    package = "netifaces";
    inherit version;
    sha256 = "0c4da523f36d36f1ef92ee183f2512f3ceb9a9d2a45f7d19cda5a42c6689ebe0";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
