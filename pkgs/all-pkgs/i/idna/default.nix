{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.8";
in
buildPythonPackage {
  name = "idna-${version}";

  src = fetchPyPi {
    package = "idna";
    inherit version;
    sha256 = "c357b3f628cf53ae2c4c05627ecc484553142ca23264e593d327bcde5e9c3407";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
