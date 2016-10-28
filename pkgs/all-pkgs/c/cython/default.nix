{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.25.1";
in
buildPythonPackage {
  name = "Cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "e0941455769335ec5afb17dee36dc3833b7edc2ae20a8ed5806c58215e4b6669";
  };

  meta = with stdenv.lib; {
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
