{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.11.10";
in
buildPythonPackage {
  name = "Werkzeug-${version}";

  src = fetchPyPi {
    package = "Werkzeug";
    inherit version;
    sha256 = "cc64dafbacc716cdd42503cf6c44cb5a35576443d82f29f6829e5c49264aeeee";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
