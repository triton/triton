{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.6.0";
in
buildPythonPackage {
  name = "defusedxml-${version}";

  src = fetchPyPi {
    package = "defusedxml";
    inherit version;
    sha256 = "f684034d135af4c6cbb949b8a4d2ed61634515257a67299e5f940fbaa34377f5";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
