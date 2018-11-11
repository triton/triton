{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.32.2";
in
buildPythonPackage rec {
  name = "wheel-${version}";

  src = fetchPyPi {
    package = "wheel";
    inherit version;
    sha256 = "196c9842d79262bb66fcf59faa4bd0deb27da911dbc7c6cdca931080eb1f0783";
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
