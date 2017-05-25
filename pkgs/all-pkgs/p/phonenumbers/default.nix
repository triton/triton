{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.5.0";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "6d3d82a3dcb0418431099d1b1c24efb280cbec8f81c7ce3d1abf417c238b8859";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
