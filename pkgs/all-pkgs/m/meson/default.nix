{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.41.1";
in
buildPythonPackage {
  name = "meson-${version}";

  src = fetchPyPi {
    package = "meson";
    inherit version;
    sha256 = "df57b79494a310d02791e3b24527536c0bcfcf8df32b30a6e4b4e071ec94ddb4";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
