{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.4.2";
in
buildPythonPackage {
  name = "pyasn1-${version}";

  src = fetchPyPi {
    package = "pyasn1";
    inherit version;
    sha256 = "d258b0a71994f7770599835249cece1caef3c70def868c4915e6e5ca49b67d15";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
