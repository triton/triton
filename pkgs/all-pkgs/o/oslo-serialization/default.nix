{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, msgpack-python
, oslo-utils
, pbr
}:

let
  version = "2.25.0";
in
buildPythonPackage {
  name = "oslo.serialization-${version}";

  src = fetchPyPi {
    package = "oslo.serialization";
    inherit version;
    sha256 = "9563fa6ff64bc0a94f8ad8d2b36c5dda452dfe3ea8bb8a5291ba0355687445c4";
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
