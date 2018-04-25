{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.3.0";
in
buildPythonPackage {
  name = "decorator-${version}";

  src = fetchPyPi {
    package = "decorator";
    inherit version;
    sha256 = "c39efa13fbdeb4506c476c9b3babf6a718da943dab7811c206005a4a956c080c";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
