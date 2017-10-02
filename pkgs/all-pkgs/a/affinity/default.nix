{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.1.0";
in
buildPythonPackage {
  name = "affinity-${version}";

  src = fetchPyPi {
    package = "affinity";
    inherit version;
    sha256 = "667141a5ab5f48e096d169bfa58c1ac7fd293ac70c9199e02ef0dbfdf53cd2c4";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
