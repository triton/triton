{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.29.6";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "6c5d33f1b5c864382fbce810a8fd9e015447869ae42e98e6301e977b8165e7ae";
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
