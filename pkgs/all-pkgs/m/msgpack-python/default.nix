{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.5.0";
in
buildPythonPackage {
  name = "msgpack-python-${version}";

  src = fetchPyPi {
    package = "msgpack-python";
    inherit version;
    sha256 = "cb31b95ed684e9b2bee184ea58bcbb27ba008123cf8c62a4bb8c281af79ecd89";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
