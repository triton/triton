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

  version = "1.12.3";
in
buildPythonPackage rec {
  name = "cffi-${version}";

  src = fetchPyPi {
    package = "cffi";
    inherit version;
    sha256 = "041c81822e9f84b1d9c401182e174996f0bae9991f33725d059b771744290774";
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
