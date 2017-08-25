{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.8.0";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "f8d5eda55e2acdfeb9db9742e1207a5cfb615ad060cabccf1e06a9ed8efd1e49";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
