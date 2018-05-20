{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.0.3";
in
buildPythonPackage {
  name = "pbr-${version}";

  src = fetchPyPi {
    package = "pbr";
    inherit version;
    sha256 = "6874feb22334a1e9a515193cba797664e940b763440c88115009ec323a7f2df5";
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
