{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, py
, setuptools-scm
}:

let
  version = "3.4.1";
in
buildPythonPackage rec {
  name = "pytest-${version}";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "9ddcb879c8cc859d2540204b5399011f842e5e8823674bf429f70ada281b3cc6";
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
