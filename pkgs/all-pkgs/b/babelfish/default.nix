{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.5.5";
in
buildPythonPackage rec {
  name = "babelfish-${version}";

  src = fetchPyPi {
    package = "babelfish";
    inherit version;
    sha256 = "8380879fa51164ac54a3e393f83c4551a275f03617f54a99d70151358e444104";
  };

  meta = with lib; {
    description = "A module to work with countries and languages";
    homepage = https://github.com/Diaoul/babelfish;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
