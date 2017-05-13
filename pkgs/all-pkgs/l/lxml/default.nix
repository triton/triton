{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, libxml2
, libxslt
}:

let
  version = "3.7.3";
in
buildPythonPackage rec {
  name = "lxml-${version}";

  src = fetchPyPi {
    package = "lxml";
    inherit version;
    sha256 = "aa502d78a51ee7d127b4824ff96500f0181d3c7826e6ee7b800d068be79361c7";
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
