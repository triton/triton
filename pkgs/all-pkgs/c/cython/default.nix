{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.27.3";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "6a00512de1f2e3ce66ba35c5420babaef1fe2d9c43a8faab4080b0dbcc26bc64";
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
