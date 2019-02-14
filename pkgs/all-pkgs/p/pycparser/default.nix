{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.19";
in
buildPythonPackage {
  name = "pycparser-${version}";

  src = fetchPyPi {
    package = "pycparser";
    inherit version;
    sha256 = "a988718abfad80b6b157acce7bf130a30876d27603738ac39f140993246b25b3";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
