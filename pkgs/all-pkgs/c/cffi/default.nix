{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, libffi
, pycparser
, python

, docs ? false
  , sphinx

, pytest
}:

let
  inherit (lib)
    optionals;

  version = "1.12.1";
in
buildPythonPackage rec {
  name = "cffi-${version}";

  src = fetchPyPi {
    package = "cffi";
    inherit version;
    sha256 = "9b6f7ba4e78c52c1a291d0c0c0bd745d19adde1a9e1c03cb899f0c6efd6f8033";
  };

  propagatedBuildInputs = [
    pycparser
  ];

  buildInputs = [
    libffi
  ] ++ optionals docs [
    sphinx
  ] ++ optionals doCheck [
    pytest
  ];

  preFixup = /* Simple test to make sure module was built */ ''
    ${python.interpreter} -c "import _cffi_backend as backend"
  '';

  checkPhase = ''
    py.test
  '';

  doCheck = false;

  meta = with lib; {
    description = "Foreign Function Interface for Python calling C code";
    homepage = http://cffi.readthedocs.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
