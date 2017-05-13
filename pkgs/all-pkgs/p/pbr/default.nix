{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.0.0";
in
buildPythonPackage {
  name = "pbr-${version}";

  src = fetchPyPi {
    package = "pbr";
    inherit version;
    sha256 = "568f988af109114fbfa0525dcb6836b069838360d11732736ecc82e4c15d5c12";
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
