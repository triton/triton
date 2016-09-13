{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.11.11";
in
buildPythonPackage {
  name = "Werkzeug-${version}";

  src = fetchPyPi {
    package = "Werkzeug";
    inherit version;
    sha256 = "e72c46bc14405cba7a26bd2ce28df734471bc9016bc8b4cb69466c2c14c2f7e5";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
