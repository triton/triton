{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.29.10";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "26229570d6787ff3caa932fe9d802960f51a89239b990d275ae845405ce43857";
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
