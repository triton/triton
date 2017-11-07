{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.8.5";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "adb2dd985f875ac035bbdc6a1cc57e30834e106e2ff7899e09a1690b474c1774";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
