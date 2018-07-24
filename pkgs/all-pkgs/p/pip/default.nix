{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "18.0";
in
buildPythonPackage rec {
  name = "pip-${version}";

  src = fetchPyPi {
    package = "pip";
    inherit version;
    sha256 = "a0e11645ee37c90b40c46d607070c4fd583e2cd46231b1c06e389c5e814eed76";
  };

  passthru = {
    inherit version;
  };

  meta = with lib; {
    description = "The PyPA recommended tool for installing Python packages";
    homepage = https://pip.pypa.io/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
