{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
, lib

, libxml2
, libxslt
}:

let
  version = "4.3.0";
in
buildPythonPackage rec {
  name = "lxml-${version}";

  src = fetchPyPi {
    package = "lxml";
    inherit version;
    sha256 = "d1e111b3ab98613115a208c1017f266478b0ab224a67bc8eac670fa0bad7d488";
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
