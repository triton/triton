{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.31.1";
in
buildPythonPackage rec {
  name = "wheel-${version}";

  src = fetchPyPi {
    package = "wheel";
    inherit version;
    sha256 = "0a2e54558a0628f2145d2fc822137e322412115173e8a2ddbe1c9024338ae83c";
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
