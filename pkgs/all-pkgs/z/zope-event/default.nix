{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.3.0";
in
buildPythonPackage rec {
  name = "zope.event-${version}";

  src = fetchPyPi {
    package = "zope.event";
    inherit version;
    sha256 = "e0ecea24247a837c71c106b0341a7a997e3653da820d21ef6c08b32548f733e7";
  };

  meta = with lib; {
    description = "An event publishing system";
    homepage = https://pypi.python.org/pypi/zope.event;
    license = licenses.zpt20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
