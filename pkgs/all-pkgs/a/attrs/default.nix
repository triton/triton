{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "17.2.0";
in
buildPythonPackage rec {
  name = "attrs-${version}";

  src = fetchPyPi {
    package = "attrs";
    inherit version;
    sha256 = "5d4d1b99f94d69338f485984127e4473b3ab9e20f43821b0e546cc3b2302fd11";
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
