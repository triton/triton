{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "20.0.2";
in
buildPythonPackage rec {
  name = "pip-${version}";

  src = fetchPyPi {
    package = "pip";
    inherit version;
    sha256 = "7db0c8ea4c7ea51c8049640e8e6e7fde949de672bfa4949920675563a5a6967f";
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
