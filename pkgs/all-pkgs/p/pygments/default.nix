{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.1.3";
in
buildPythonPackage {
  name = "Pygments-${version}";

  src = fetchPyPi {
    package = "Pygments";
    inherit version;
    sha256 = "88e4c8a91b2af5962bfa5ea2447ec6dd357018e86e94c7d14bd8cacbc5b55d81";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
