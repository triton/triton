{ stdenv
, buildPythonPackage
, fetchPyPi
, isPyPy
, lib
}:

let
  version = "0.4.13";
in
buildPythonPackage rec {
  name = "greenlet-${version}";

  src = fetchPyPi {
    package = "greenlet";
    inherit version;
    sha256 = "0fef83d43bf87a5196c91e73cb9772f945a4caaff91242766c5916d1dd1381e4";
  };

  # Builtin for pypy
  disabled = isPyPy;

  meta = with lib; {
    description = "Module for lightweight in-process concurrent programming";
    homepage = https://pypi.python.org/pypi/greenlet;
    license = licenses.lgpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
