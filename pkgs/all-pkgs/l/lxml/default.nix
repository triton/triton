{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
, lib

, libxml2
, libxslt
}:

let
  version = "4.3.3";
in
buildPythonPackage rec {
  name = "lxml-${version}";

  src = fetchPyPi {
    package = "lxml";
    inherit version;
    sha256 = "4a03dd682f8e35a10234904e0b9508d705ff98cf962c5851ed052e9340df3d90";
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
