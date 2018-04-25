{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.6.1";
in
buildPythonPackage {
  name = "pycryptodomex-${version}";

  src = fetchPyPi {
    package = "pycryptodomex";
    inherit version;
    sha256 = "82b758f870c8dd859f9b58bc9cff007403b68742f9e0376e2cbd8aa2ad3baa83";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
