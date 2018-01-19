{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2018.1.18";
in
buildPythonPackage rec {
  name = "certifi-${version}";

  src = fetchPyPi {
    package = "certifi";
    inherit version;
    sha256 = "edbc3f203427eef571f79a7692bb160a2b0f7ccaa31953e99bd17e307cf63f7d";
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
