{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.15.2";
in
buildPythonPackage {
  name = "future-${version}";

  src = fetchPyPi {
    package = "future";
    inherit version;
    sha256 = "3d3b193f20ca62ba7d8782589922878820d0a023b885882deec830adbf639b97";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
