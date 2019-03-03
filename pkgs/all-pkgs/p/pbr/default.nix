{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "5.1.3";
in
buildPythonPackage {
  name = "pbr-${version}";

  src = fetchPyPi {
    package = "pbr";
    inherit version;
    sha256 = "8c361cc353d988e4f5b998555c88098b9d5964c2e11acf7b0d21925a66bb5824";
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
