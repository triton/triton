{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "7.2.0";
in
buildPythonPackage {
  name = "more-itertools-${version}";

  src = fetchPyPi {
    package = "more-itertools";
    inherit version;
    sha256 = "409cd48d4db7052af495b09dec721011634af3753ae1ef92d2b32f73a745f832";
  };

  meta = with lib; {
    description = "More routines for operating on iterables, beyond itertools";
    homepage = https://github.com/erikrose/more-itertools;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
