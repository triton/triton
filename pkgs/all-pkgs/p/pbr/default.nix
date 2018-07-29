{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.2.0";
in
buildPythonPackage {
  name = "pbr-${version}";

  src = fetchPyPi {
    package = "pbr";
    inherit version;
    sha256 = "1b8be50d938c9bb75d0eaf7eda111eec1bf6dc88a62a6412e33bf077457e0f45";
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
