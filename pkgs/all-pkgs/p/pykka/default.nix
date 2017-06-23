{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.2.1";
in
buildPythonPackage rec {
  name = "pykka-${version}";

  src = fetchPyPi {
    package = "Pykka";
    inherit version;
    sha256 = "e847ffeadee49b563426ab803e8eee67264d773e38ca14763fdcda56411e3c11";
  };

  meta = with lib; {
    description = "A Python implementation of the actor model";
    homepage = https://www.pykka.org;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
