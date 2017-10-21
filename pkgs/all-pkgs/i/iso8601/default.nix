{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.1.12";
in
buildPythonPackage {
  name = "iso8601-${version}";

  src = fetchPyPi {
    package = "iso8601";
    inherit version;
    sha256 = "49c4b20e1f38aa5cf109ddcd39647ac419f928512c869dc01d5c7098eddede82";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
