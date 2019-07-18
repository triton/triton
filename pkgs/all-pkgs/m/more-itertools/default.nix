{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "7.1.0";
in
buildPythonPackage {
  name = "more-itertools-${version}";

  src = fetchPyPi {
    package = "more-itertools";
    inherit version;
    sha256 = "8bb43d1f51ecef60d81854af61a3a880555a14643691cc4b64a6ee269c78f09a";
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
