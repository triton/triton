{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, unzip
}:

let
  version = "0.45.1";
in
buildPythonPackage rec {
  name = "olefile-${version}";

  src = fetchPyPi {
    package = "olefile";
    inherit version;
    type = ".zip";
    sha256 = "2b6575f5290de8ab1086f8c5490591f7e0885af682c7c1793bdaf6e64078d385";
  };

  nativeBuildInputs = [
    unzip
  ];

  meta = with lib; {
    description = "Package to parse, read and write Microsoft OLE2 files";
    homepage = http://www.decalage.info/python/olefileio;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
