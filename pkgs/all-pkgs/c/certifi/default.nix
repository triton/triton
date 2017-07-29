{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2017.7.27";
in
buildPythonPackage rec {
  name = "certifi-${version}";

  src = fetchPyPi {
    package = "certifi";
    inherit version;
    sha256 = "a7e03cbaf96baad108e34602848d0e4f04e59185325a61e63c96fcf67cee5fcd";
  };

  meta = with lib; {
    description = "Python package for providing Mozilla's CA Bundle";
    homepage = http://certifi.io/;
    license = licenses.isc;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
