{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.3.6";
in
buildPythonPackage {
  name = "blist-${version}";

  src = fetchPyPi {
    package = "blist";
    inherit version;
    sha256 = "3a12c450b001bdf895b30ae818d4d6d3f1552096b8c995f0fe0c74bef04d1fc3";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
