{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.44";
in
buildPythonPackage rec {
  name = "olefile-${version}";

  src = fetchPyPi {
    package = "olefile";
    inherit version;
    type = ".zip";
    sha256 = "61f2ca0cd0aa77279eb943c07f607438edf374096b66332fae1ee64a6f0f73ad";
  };

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
