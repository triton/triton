{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "5.0.0";
in
buildPythonPackage {
  name = "pbr-${version}";

  src = fetchPyPi {
    package = "pbr";
    inherit version;
    sha256 = "ab94783019179bf48f5784edc63f5bc8328ec5ff93f33591567f266d21ac7323";
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
