{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, msgpack-python
, oslo-utils
, pbr
}:

let
  version = "2.24.0";
in
buildPythonPackage {
  name = "oslo.serialization-${version}";

  src = fetchPyPi {
    package = "oslo.serialization";
    inherit version;
    sha256 = "61ca03df07f84d6ad73790b3e1803bd5b91809c11d0cd351f1271886d29d7d21";
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
