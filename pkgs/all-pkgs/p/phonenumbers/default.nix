{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.8.7";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "774fdd298d3c2e2236793775533f8912a74d0115e4d9ec1d2bd3eaafb55095fc";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
