{ stdenv
, buildPythonPackage
, fetchPyPi

, libffi
, pycparser
, python

, docs ? false
  , sphinx

, pytest
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "1.9.1";
in
buildPythonPackage rec {
  name = "cffi-${version}";

  src = fetchPyPi {
    package = "cffi";
    inherit version;
    sha256 = "563e0bd53fda03c151573217b3a49b3abad8813de9dd0632e10090f6190fdaf8";
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

  meta = with stdenv.lib; {
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
