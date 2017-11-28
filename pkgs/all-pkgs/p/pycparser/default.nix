{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, isPy3
}:

let
  version = "2.18";
in
buildPythonPackage {
  name = "pycparser-${version}";

  src = fetchPyPi {
    package = "pycparser";
    inherit version;
    sha256 = "99a8ca03e29851d96616ad0404b4aad7d9ee16f25c9f9708a11faf2810f7b226";
  };

  # Fails currently for the python3 build
  buildDirCheck = !isPy3;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
