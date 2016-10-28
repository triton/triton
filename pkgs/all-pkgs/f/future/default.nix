{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.16.0";
in
buildPythonPackage {
  name = "future-${version}";

  src = fetchPyPi {
    package = "future";
    inherit version;
    sha256 = "e39ced1ab767b5936646cedba8bcce582398233d6a627067d4c6a454c90cfedb";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
