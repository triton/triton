{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.7.4";
in
buildPythonPackage {
  name = "webob-${version}";

  src = fetchPyPi {
    package = "WebOb";
    inherit version;
    sha256 = "8d10af182fda4b92193113ee1edeb687ab9dc44336b37d6804e413f0240d40d9";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
