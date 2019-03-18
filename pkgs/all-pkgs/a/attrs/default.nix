{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "19.1.0";
in
buildPythonPackage rec {
  name = "attrs-${version}";

  src = fetchPyPi {
    package = "attrs";
    inherit version;
    sha256 = "f0b870f674851ecbfbbbd364d6b5cbdff9dcedbc7f3f5e18a6891057f21fe399";
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
