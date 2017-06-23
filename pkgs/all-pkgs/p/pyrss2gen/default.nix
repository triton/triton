{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.1";
in
buildPythonPackage rec {
  name = "pyrss2gen-${version}";

  src = fetchPyPi {
    package = "PyRSS2Gen";
    inherit version;
    sha256 = "7960aed7e998d2482bf58716c316509786f596426f879b05f8d84e98b82c6ee7";
  };

  doCheck = true;

  meta = with lib; {
    description = "Generate RSS2 using a Python data structure";
    homepage = http://www.dalkescientific.om/Python/PyRSS2Gen.html;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
