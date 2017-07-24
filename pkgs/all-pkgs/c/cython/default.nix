{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.26";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "4c24e2c22ddaed624d35229dc5db25049e9e225c6f64f3364326836cad8f2c66";
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
