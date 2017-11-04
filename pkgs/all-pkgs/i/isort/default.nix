{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.2.15";
in
buildPythonPackage rec {
  name = "isort-${version}";

  src = fetchPyPi {
    package = "isort";
    inherit version;
    sha256 = "79f46172d3a4e2e53e7016e663cc7a8b538bec525c36675fcfd2767df30b3983";
  };

  meta = with lib; {
    description = "Library to sort Python imports";
    homepage = https://github.com/timothycrosley/isort;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
