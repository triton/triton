{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.5.0";
in
buildPythonPackage {
  name = "daemonize-${version}";

  src = fetchPyPi {
    package = "daemonize";
    inherit version;
    sha256 = "dd026e4ff8d22cb016ed2130bc738b7d4b1da597ef93c074d2adb9e4dea08bc3";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
