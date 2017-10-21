{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, msgpack-python
, oslo-utils
, pbr
}:

let
  version = "2.13.2";
in
buildPythonPackage {
  name = "oslo.serialization-${version}";

  src = fetchPyPi {
    package = "oslo.serialization";
    inherit version;
    sha256 = "aade58171aa87360c35be4a7df232564bfa0db33d203657cea1ee73bdf1de7f0";
  };

  propagatedBuildInputs = [
    msgpack-python
    oslo-utils
    pbr
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
