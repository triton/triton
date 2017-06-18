{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.5";
in
buildPythonPackage {
  name = "idna-${version}";

  src = fetchPyPi {
    package = "idna";
    inherit version;
    sha256 = "3cb5ce08046c4e3a560fc02f138d0ac63e00f8ce5901a56b32ec8b7994082aab";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
