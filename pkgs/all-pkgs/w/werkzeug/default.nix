{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.15.1";
in
buildPythonPackage {
  name = "werkzeug-${version}";

  src = fetchPyPi {
    package = "Werkzeug";
    inherit version;
    sha256 = "ca5c2dcd367d6c0df87185b9082929d255358f5391923269335782b213d52655";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
