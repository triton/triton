{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.40";
in
buildPythonPackage rec {
  name = "olefile-${version}";

  src = fetchPyPi {
    package = "olefile";
    inherit version;
    type = ".zip";
    sha256 = "75e889e2e49a76f7387ea935e54c70fd8762fc56860d86a5695f92111a63c335";
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
