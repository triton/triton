{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.0.18";
in
buildPythonPackage {
  name = "ipaddress-${version}";

  src = fetchPyPi {
    package = "ipaddress";
    inherit version;
    sha256 = "5d8534c8e185f2d8a1fda1ef73f2c8f4b23264e8e30063feeb9511d492a413e1";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
