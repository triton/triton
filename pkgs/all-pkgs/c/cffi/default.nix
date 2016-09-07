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

  version = "1.8.2";
in
buildPythonPackage rec {
  name = "cffi-${version}";

  src = fetchPyPi {
    package = "cffi";
    inherit version;
    sha256 = "2b636db1a179439d73ae0a090479e179a43df5d4eddc7e4c4067f960d4038530";
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
