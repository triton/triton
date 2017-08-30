{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.26.1";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "c2e63c4794161135adafa8aa4a855d6068073f421c83ffacc39369497a189dd5";
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
