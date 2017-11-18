{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.4.3";
in
buildPythonPackage rec {
  name = "appdirs-${version}";

  src = fetchPyPi {
    package = "appdirs";
    inherit version;
    sha256 = "9e5896d1372858f8dd3344faf4e5014d21849c756c8d5701f78f8a103b372d92";
  };

  passthru = {
    inherit version;
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
