{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.2.1";
in
buildPythonPackage {
  name = "decorator-${version}";

  src = fetchPyPi {
    package = "decorator";
    inherit version;
    sha256 = "7d46dd9f3ea1cf5f06ee0e4e1277ae618cf48dfb10ada7c8427cd46c42702a0e";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
