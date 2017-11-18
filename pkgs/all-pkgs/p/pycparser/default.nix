{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.17";
in
buildPythonPackage {
  name = "pycparser-${version}";

  src = fetchPyPi {
    package = "pycparser";
    inherit version;
    sha256 = "0aac31e917c24cb3357f5a4d5566f2cc91a19ca41862f6c3c22dc60a629673b6";
  };

  buildDirCheck = false;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
