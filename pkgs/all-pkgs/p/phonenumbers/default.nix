{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.7.1";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "f951bc2737feac08ef51c3183ec6993d31e5fc1212e25cbbf3916c037717b1fe";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
