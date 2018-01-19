{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.14";
in
buildPythonPackage {
  name = "werkzeug-${version}";

  src = fetchPyPi {
    package = "Werkzeug";
    inherit version;
    sha256 = "4aea27a9513b056346e9c8b49107f4ee7927f7bcf0be63024ecee39d5b87e9ef";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
