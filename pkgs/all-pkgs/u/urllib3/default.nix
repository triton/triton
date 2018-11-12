{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.24.1";
in
buildPythonPackage {
  name = "urllib3-${version}";

  src = fetchPyPi {
    package = "urllib3";
    inherit version;
    sha256 = "de9529817c93f27c8ccbfead6985011db27bd0ddfcdb2d86f3f663385c6a9c22";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
