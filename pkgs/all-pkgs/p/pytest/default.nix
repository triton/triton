{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, py
}:

let
  version = "3.0.7";
in
buildPythonPackage rec {
  name = "pytest-${version}";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "b70696ebd1a5e6b627e7e3ac1365a4bc60aaf3495e843c1e70448966c5224cab";
  };

  propagatedBuildInputs = [
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
