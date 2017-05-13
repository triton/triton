{ stdenv
, buildPythonPackage
, fetchPyPi
, isPyPy
, lib
}:

let
  version = "0.4.12";
in
buildPythonPackage rec {
  name = "greenlet-${version}";

  src = fetchPyPi {
    package = "greenlet";
    inherit version;
    sha256 = "e4c99c6010a5d153d481fdaf63b8a0782825c0721506d880403a3b9b82ae347e";
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
