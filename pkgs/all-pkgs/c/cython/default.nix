{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.29.5";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "9d5290d749099a8e446422adfb0aa2142c711284800fb1eb70f595101e32cbf1";
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
