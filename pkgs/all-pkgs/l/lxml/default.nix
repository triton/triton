{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, libxml2
, libxslt
}:

let
  version = "4.1.0";
in
buildPythonPackage rec {
  name = "lxml-${version}";

  src = fetchPyPi {
    package = "lxml";
    inherit version;
    sha256 = "be3aaeb5f468a49f523f16736ccff7d82af2b4b303292ba3d052b5b28f3fbe47";
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
