{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.11.0";
in
buildPythonPackage {
  name = "requests-${version}";

  src = fetchPyPi {
    package = "requests";
    inherit version;
    sha256 = "b2ff053e93ef11ea08b0e596a1618487c4e4c5f1006d7a1706e3671c57dea385";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
