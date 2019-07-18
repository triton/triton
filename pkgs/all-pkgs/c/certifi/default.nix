{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2019.6.16";
in
buildPythonPackage rec {
  name = "certifi-${version}";

  src = fetchPyPi {
    package = "certifi";
    inherit version;
    sha256 = "945e3ba63a0b9f577b1395204e13c3a231f9bc0223888be653286534e5873695";
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
