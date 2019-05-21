{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.6.0";
in
buildPythonPackage {
  name = "fido2-${version}";

  src = fetchPyPi {
    package = "fido2";
    inherit version;
    sha256 = "7541edad31967d23f5006ffeccc54536ab9934dd981d65d29620d9dfb54566bf";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
