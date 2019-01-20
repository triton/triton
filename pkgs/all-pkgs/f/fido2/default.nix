{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.5.0";
in
buildPythonPackage {
  name = "fido2-${version}";

  src = fetchPyPi {
    package = "fido2";
    inherit version;
    sha256 = "e356c4e2ff136a29ea7f0bf82e679c2251fb246c4d459c3c91f84b93af6888de";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
