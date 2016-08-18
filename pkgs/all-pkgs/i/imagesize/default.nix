{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.7.1";
in
buildPythonPackage {
  name = "imagesize-${version}";

  src = fetchPyPi {
    package = "imagesize";
    inherit version;
    sha256 = "0ab2c62b87987e3252f89d30b7cedbec12a01af9274af9ffa48108f2c13c6062";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
