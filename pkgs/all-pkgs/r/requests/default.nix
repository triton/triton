{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.12.1";
in
buildPythonPackage {
  name = "requests-${version}";

  src = fetchPyPi {
    package = "requests";
    inherit version;
    sha256 = "2109ecea94df90980be040490ff1d879971b024861539abb00054062388b612e";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
