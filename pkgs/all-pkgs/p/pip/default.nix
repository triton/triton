{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "10.0.1";
in
buildPythonPackage rec {
  name = "pip-${version}";

  src = fetchPyPi {
    package = "pip";
    inherit version;
    sha256 = "f2bd08e0cd1b06e10218feaf6fef299f473ba706582eb3bd9d52203fdbd7ee68";
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
