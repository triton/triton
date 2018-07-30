{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
, lib

, libxml2
, libxslt
}:

let
  version = "4.2.3";
in
buildPythonPackage rec {
  name = "lxml-${version}";

  src = fetchPyPi {
    package = "lxml";
    inherit version;
    sha256 = "622f7e40faef13d232fb52003661f2764ce6cdef3edb0a59af7c1559e4cc36d1";
  };

  nativeBuildInputs = [
    cython
  ];

  propagatedBuildInputs = [
    libxml2
    libxslt
  ];

  postPatch = /* Force cython files to be regenerated */ ''
    rm src/lxml/*.c
  '';

  meta = with lib; {
    description = "Pythonic binding for the libxml2 and libxslt libraries";
    homepage = http://lxml.de;
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
