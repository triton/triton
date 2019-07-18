{ stdenv
, buildPythonPackage
, fetchPyPi
, isPyPy
, lib
}:

let
  version = "0.4.15";
in
buildPythonPackage rec {
  name = "greenlet-${version}";

  src = fetchPyPi {
    package = "greenlet";
    inherit version;
    sha256 = "9416443e219356e3c31f1f918a91badf2e37acf297e2fa13d24d1cc2380f8fbc";
  };

  # Builtin for pypy
  disabled = isPyPy;

  meta = with lib; {
    description = "Module for lightweight in-process concurrent programming";
    homepage = https://github.com/python-greenlet/greenlet;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
