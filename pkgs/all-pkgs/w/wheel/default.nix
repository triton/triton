{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.31.0";
in
buildPythonPackage rec {
  name = "wheel-${version}";

  src = fetchPyPi {
    package = "wheel";
    inherit version;
    sha256 = "1ae8153bed701cb062913b72429bcf854ba824f973735427681882a688cb55ce";
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
