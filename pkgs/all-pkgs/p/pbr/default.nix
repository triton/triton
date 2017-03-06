{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.0.0";
in
buildPythonPackage {
  name = "pbr-${version}";

  src = fetchPyPi {
    package = "pbr";
    inherit version;
    sha256 = "0ccd2db529afd070df815b1521f01401d43de03941170f8a800e7531faba265d";
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
