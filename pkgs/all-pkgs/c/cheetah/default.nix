{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.4.4";
in
buildPythonPackage {
  name = "Cheetah-${version}";

  src = fetchPyPi {
    package = "Cheetah";
    inherit version;
    sha256 = "be308229f0c1e5e5af4f27d7ee06d90bb19e6af3059794e5fd536a6f29a9b550";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
