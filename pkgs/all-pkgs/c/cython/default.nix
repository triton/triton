{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.29.13";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "c29d069a4a30f472482343c866f7486731ad638ef9af92bfe5fca9c7323d638e";
  };

  meta = with lib; {
    description = "A static compiler for Python & Cython programming languages";
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
