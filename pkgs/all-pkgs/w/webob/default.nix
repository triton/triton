{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.8.1";
in
buildPythonPackage {
  name = "webob-${version}";

  src = fetchPyPi {
    package = "WebOb";
    inherit version;
    sha256 = "54f35073d2fdcddd7a98c2a1dedeede49739150737164a787220f30283139ba6";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
