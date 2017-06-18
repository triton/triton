{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, libxml2
, libxslt
}:

let
  version = "3.8.0";
in
buildPythonPackage rec {
  name = "lxml-${version}";

  src = fetchPyPi {
    package = "lxml";
    inherit version;
    sha256 = "736f72be15caad8116891eb6aa4a078b590d231fdc63818c40c21624ac71db96";
  };

  propagatedBuildInputs = [
    libxml2
    libxslt
  ];

  meta = with lib; {
    description = "Pythonic binding for the libxml2 and libxslt libraries";
    homepage = http://lxml.de;
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
