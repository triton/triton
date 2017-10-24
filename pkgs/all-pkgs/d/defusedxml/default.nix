{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.5.0";
in
buildPythonPackage {
  name = "defusedxml-${version}";

  src = fetchPyPi {
    package = "defusedxml";
    inherit version;
    sha256 = "24d7f2f94f7f3cb6061acb215685e5125fbcdc40a857eff9de22518820b0a4f4";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
