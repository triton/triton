{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, libxml2
, libxslt
}:

let
  version = "4.0.0";
in
buildPythonPackage rec {
  name = "lxml-${version}";

  src = fetchPyPi {
    package = "lxml";
    inherit version;
    sha256 = "f7bc9f702500e205b1560d620f14015fec76dcd6f9e889a946a2ddcc3c344fd0";
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
