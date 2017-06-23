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

  version = "1.10.0";
in
buildPythonPackage rec {
  name = "cffi-${version}";

  src = fetchPyPi {
    package = "cffi";
    inherit version;
    sha256 = "b3b02911eb1f6ada203b0763ba924234629b51586f72a21faacc638269f4ced5";
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
