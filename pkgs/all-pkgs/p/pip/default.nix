{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "9.0.1";
in
buildPythonPackage rec {
  name = "pip-${version}";

  src = fetchPyPi {
    package = "pip";
    inherit version;
    sha256 = "09f243e1a7b461f654c26a725fa373211bb7ff17a9300058b205c61658ca940d";
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
