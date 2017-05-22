{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.0.1";
in
buildPythonPackage {
  name = "pbr-${version}";

  src = fetchPyPi {
    package = "pbr";
    inherit version;
    sha256 = "d7e8917458094002b9a2e0030ba60ba4c834c456071f2d0c1ccb5265992ada91";
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
