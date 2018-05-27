{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.28.3";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "1aae6d6e9858888144cea147eb5e677830f45faaff3d305d77378c3cba55f526";
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
