{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.0.2";
in
buildPythonPackage {
  name = "pbr-${version}";

  src = fetchPyPi {
    package = "pbr";
    inherit version;
    sha256 = "dae4aaa78eafcad10ce2581fc34d694faa616727837fd8e55c1a00951ad6744f";
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
