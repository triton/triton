{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
, lib

, libxml2
, libxslt
}:

let
  version = "4.1.1";
in
buildPythonPackage rec {
  name = "lxml-${version}";

  src = fetchPyPi {
    package = "lxml";
    inherit version;
    sha256 = "940caef1ec7c78e0c34b0f6b94fe42d0f2022915ffc78643d28538a5cfd0f40e";
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
