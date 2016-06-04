{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.35";
in
buildPythonPackage {
  name = "ujson-${version}";

  src = fetchPyPi {
    package = "ujson";
    inherit version;
    sha256 = "f66073e5506e91d204ab0c614a148d5aa938bdbf104751be66f8ad7a222f5f86";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
