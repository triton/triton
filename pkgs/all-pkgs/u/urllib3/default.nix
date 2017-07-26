{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.22";
in
buildPythonPackage {
  name = "urllib3-${version}";

  src = fetchPyPi {
    package = "urllib3";
    inherit version;
    sha256 = "cc44da8e1145637334317feebd728bd869a35285b93cbb4cca2577da7e62db4f";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
