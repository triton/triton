{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.9.2";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "9c60423cdd0eee3a65dd2d8280fab08e4d9fa4675dce1651c164a6408fecacfc";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
