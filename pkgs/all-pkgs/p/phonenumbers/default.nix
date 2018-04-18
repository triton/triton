{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.9.4";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "c7eb13c2a80fd03df82cfeb1e13a2acc3d7767e9671cf0bd45d8586e7b7811d3";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
