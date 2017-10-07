{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.3.6";
in
buildPythonPackage {
  name = "pyasn1-${version}";

  src = fetchPyPi {
    package = "pyasn1";
    inherit version;
    sha256 = "f0380ea97db0ede095a0dd87ce3003d46c197191f924206e43f776fc77e51f09";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
