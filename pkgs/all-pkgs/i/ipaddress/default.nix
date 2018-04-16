{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.0.22";
in
buildPythonPackage {
  name = "ipaddress-${version}";

  src = fetchPyPi {
    package = "ipaddress";
    inherit version;
    sha256 = "b146c751ea45cad6188dd6cf2d9b757f6f4f8d6ffb96a023e6f2e26eea02a72c";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
