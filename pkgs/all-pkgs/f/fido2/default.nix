{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.4.0";
in
buildPythonPackage {
  name = "fido2-${version}";

  src = fetchPyPi {
    package = "fido2";
    inherit version;
    sha256 = "f8d84aef5b54cccfb5558f399f196d540f8dcba458862214c14f7f66c22a4488";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
