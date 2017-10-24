{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.27.2";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "265dacf64ed8c0819f4be9355c39beaa13dc2ad2f85237a2c4e478f5ce644b48";
  };

  meta = with lib; {
    description = "An optimising static compiler for the Python and Cython programming languages";
    homepage = http://cython.org;
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
