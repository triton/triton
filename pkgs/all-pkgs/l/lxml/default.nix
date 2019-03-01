{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
, lib

, libxml2
, libxslt
}:

let
  version = "4.3.2";
in
buildPythonPackage rec {
  name = "lxml-${version}";

  src = fetchPyPi {
    package = "lxml";
    inherit version;
    sha256 = "3a9d8521c89bf6f2a929c3d12ad3ad7392c774c327ea809fd08a13be6b3bc05f";
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
