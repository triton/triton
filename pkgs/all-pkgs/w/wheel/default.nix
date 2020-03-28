{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.34.2";
in
buildPythonPackage rec {
  name = "wheel-${version}";

  src = fetchPyPi {
    package = "wheel";
    inherit version;
    sha256 = "8788e9155fe14f54164c1b9eb0a319d98ef02c160725587ad60f14ddc57b6f96";
  };

  passthru = {
    inherit version;
  };

  meta = with lib; {
    description = "A built-package format for Python";
    homepage = https://bitbucket.org/pypa/wheel/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
