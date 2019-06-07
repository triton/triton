{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "5.2.1";
in
buildPythonPackage {
  name = "pbr-${version}";

  src = fetchPyPi {
    package = "pbr";
    inherit version;
    sha256 = "93d2dc6ee0c9af4dbc70bc1251d0e545a9910ca8863774761f92716dece400b6";
  };

  meta = with lib; {
    description = "Injects default behaviors into setuptools";
    homepage = https://launchpad.net/pbr;
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
