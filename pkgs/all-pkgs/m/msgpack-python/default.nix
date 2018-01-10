{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.5.1";
in
buildPythonPackage {
  name = "msgpack-python-${version}";

  src = fetchPyPi {
    package = "msgpack-python";
    inherit version;
    sha256 = "69aa1eb0e13be1d3bd495ca937eae66df4431126f5cfd5491dc40370e5644853";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
