{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.28.2";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "634e2f10fc8d026c633cffacb45cd8f4582149fa68e1428124e762dbc566e68a";
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
