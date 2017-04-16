{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.4.0";
in
buildPythonPackage {
  name = "asciinema-${version}";

  src = fetchPyPi {
    package = "asciinema";
    inherit version;
    sha256 = "fb31457e7a4689340b872f625658dbaea33bcf6863fb5d696cf3857010432ecb";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
