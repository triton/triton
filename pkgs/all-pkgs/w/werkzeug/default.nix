{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.14.1";
in
buildPythonPackage {
  name = "werkzeug-${version}";

  src = fetchPyPi {
    package = "Werkzeug";
    inherit version;
    sha256 = "c3fd7a7d41976d9f44db327260e263132466836cef6f91512889ed60ad26557c";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
