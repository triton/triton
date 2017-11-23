{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, msgpack-python
, oslo-utils
, pbr
}:

let
  version = "2.20.1";
in
buildPythonPackage {
  name = "oslo.serialization-${version}";

  src = fetchPyPi {
    package = "oslo.serialization";
    inherit version;
    sha256 = "f9d373733811967ffa39455f9167d4e65158e26bbe80ae2e358b631790280832";
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
