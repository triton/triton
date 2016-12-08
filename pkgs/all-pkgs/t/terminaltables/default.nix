{ buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.1.0";
in
buildPythonPackage rec {
  name = "terminaltables-${version}";

  src = fetchPyPi {
    package = "terminaltables";
    inherit version;
    sha256 = "f3eb0eb92e3833972ac36796293ca0906e998dc3be91fbe1f8615b331b853b81";
  };

  meta = with lib; {
    description = "Simple tables in terminals from a nested list of strings";
    homepage = https://github.com/Robpol86/terminaltables;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
