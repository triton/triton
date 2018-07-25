{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.28.4";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "76ac2b08d3d956d77b574bb43cbf1d37bd58b9d50c04ba281303e695854ebc46";
  };

  meta = with lib; {
    description = "An optimising static compiler for the Python and Cython programming languages";
    homepage = http://cython.org;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
