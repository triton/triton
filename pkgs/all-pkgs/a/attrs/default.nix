{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "17.3.0";
in
buildPythonPackage rec {
  name = "attrs-${version}";

  src = fetchPyPi {
    package = "attrs";
    inherit version;
    sha256 = "c78f53e32d7cf36d8597c8a2c7e3c0ad210f97b9509e152e4c37fa80869f823c";
  };

  meta = with lib; {
    description = "Attributes without boilerplate";
    homepage = https://github.com/hynek/attrs;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
