{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.6.2";
in
buildPythonPackage {
  name = "docopt-${version}";

  src = fetchPyPi {
    package = "docopt";
    inherit version;
    sha256 = "49b3a825280bd66b3aa83585ef59c4a8c82f2c8a522dbe754a8bc8d08c85c491";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
