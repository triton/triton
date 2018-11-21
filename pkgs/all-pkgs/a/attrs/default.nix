{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "18.2.0";
in
buildPythonPackage rec {
  name = "attrs-${version}";

  src = fetchPyPi {
    package = "attrs";
    inherit version;
    sha256 = "10cbf6e27dbce8c30807caf056c8eb50917e0eaafe86347671b57254006c3e69";
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
