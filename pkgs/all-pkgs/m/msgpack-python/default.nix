{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.5.4";
in
buildPythonPackage {
  name = "msgpack-python-${version}";

  src = fetchPyPi {
    package = "msgpack-python";
    inherit version;
    sha256 = "c1f3f8d02206f84258a3b4f99fbc0a4e3c849721c9361196c3bfd5243e4304cd";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
