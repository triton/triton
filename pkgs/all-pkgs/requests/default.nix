{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.10.0";
in
buildPythonPackage {
  name = "requests-${version}";

  src = fetchPyPi {
    package = "requests";
    inherit version;
    sha256 = "63f1815788157130cee16a933b2ee184038e975f0017306d723ac326b5525b54";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
