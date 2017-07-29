{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.3.1";
in
buildPythonPackage {
  name = "pyasn1-${version}";

  src = fetchPyPi {
    package = "pyasn1";
    inherit version;
    sha256 = "f6e437000baec5feda6bc4c04acaf7ca25bbca76a6cbce142ebbfada12244fac";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
