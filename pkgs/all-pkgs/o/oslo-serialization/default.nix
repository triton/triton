{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, msgpack-python
, oslo-utils
, pbr
}:

let
  version = "2.22.0";
in
buildPythonPackage {
  name = "oslo.serialization-${version}";

  src = fetchPyPi {
    package = "oslo.serialization";
    inherit version;
    sha256 = "12a17687efedc2e589c1086c9544399e46654e27fe5464a0a69405d8631f4b51";
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
