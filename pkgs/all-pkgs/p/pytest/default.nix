{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, py
, setuptools-scm
}:

let
  version = "3.5.1";
in
buildPythonPackage rec {
  name = "pytest-${version}";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "54713b26c97538db6ff0703a12b19aeaeb60b5e599de542e7fca0ec83b9038e8";
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
