{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.4.6";
in
buildPythonPackage {
  name = "daemonize-${version}";

  src = fetchPyPi {
    package = "daemonize";
    inherit version;
    sha256 = "8aa66bad9aa10c682302a4ea9675874191304adeb3239e0776f1ca3041d30619";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
