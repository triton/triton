{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.4.0";
in
buildPythonPackage rec {
  name = "appdirs-${version}";

  src = fetchPyPi {
    package = "appdirs";
    inherit version;
    sha256 = "8fc245efb4387a4e3e0ac8ebcc704582df7d72ff6a42a53f5600bbb18fdaadc5";
  };

  meta = with lib; {
    description = "Python module for determining platform-specific directories";
    homepage = https://github.com/ActiveState/appdirs;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
