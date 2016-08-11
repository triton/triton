{ stdenv
, buildPythonPackage
, fetchPyPi
, pythonPackages
}:

let
  inherit (pythonPackages)
    pythonAtLeast;
in
buildPythonPackage rec {
  name = "pathlib-${version}";
  version = "1.0.1";

  src = fetchPyPi {
    package = "pathlib";
    inherit version;
    sha256 = "6940718dfc3eff4258203ad5021090933e5c04707d5ca8cc9e73c94a7894ea9f";
  };

  # Was added to standard library in Python 3.4
  disabled = pythonAtLeast "3.4";
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Object-oriented filesystem paths";
    homepage = "https://pathlib.readthedocs.org/";
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
