{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, py
, setuptools-scm
}:

let
  version = "3.2.3";
in
buildPythonPackage rec {
  name = "pytest-${version}";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "27fa6617efc2869d3e969a3e75ec060375bfb28831ade8b5cdd68da3a741dc3c";
  };

  propagatedBuildInputs = [
    setuptools-scm
    py
  ];

  meta = with lib; {
    description = "Simple powerful testing framework for Python";
    homepage = https://pytest.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
