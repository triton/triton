{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.15.34";
in
buildPythonPackage {
  name = "ruamel.yaml-${version}";

  src = fetchPyPi {
    package = "ruamel.yaml";
    inherit version;
    sha256 = "f1e29054c6e477963e302b007b6cd1d6c7a58c38d78fabe64fde9ce170d2d1fd";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
