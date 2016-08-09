{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.24.1";
in
buildPythonPackage {
  name = "Cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "84808fda00508757928e1feadcf41c9f78e9a9b7167b6649ab0933b76f75e7b9";
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
