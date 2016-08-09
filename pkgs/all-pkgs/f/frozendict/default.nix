{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.6";
in
buildPythonPackage {
  name = "frozendict-${version}";

  src = fetchPyPi {
    package = "frozendict";
    inherit version;
    sha256 = "168791393c2c642264a6839aac5e7c6a34b3a284aa02b8c950739962f756163c";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
