{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2018.11.29";
in
buildPythonPackage rec {
  name = "certifi-${version}";

  src = fetchPyPi {
    package = "certifi";
    inherit version;
    sha256 = "47f9c83ef4c0c621eaef743f133f09fa8a74a9b75f037e8624f83bd1b6626cb7";
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
