{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.8.10";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "6ebf1ac9d2ae9cbbdd8d62fb5d1f66b0b2989d0e0dea7cc3d4f377e01b4fd640";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
