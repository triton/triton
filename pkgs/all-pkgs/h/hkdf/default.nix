{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.0.3";
in
buildPythonPackage {
  name = "hkdf-${version}";

  src = fetchPyPi {
    package = "hkdf";
    inherit version;
    sha256 = "622a31c634bc185581530a4b44ffb731ed208acf4614f9c795bdd70e77991dca";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
