{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.25.2";
in
buildPythonPackage {
  name = "Cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "f141d1f9c27a07b5a93f7dc5339472067e2d7140d1c5a9e20112a5665ca60306";
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
