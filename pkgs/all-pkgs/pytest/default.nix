{ stdenv
, buildPythonPackage
, fetchPyPi

, isPy3k
, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionalString;
in

buildPythonPackage rec {
  name = "pytest-${version}";
  version = "2.9.1";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "0d48d27a127644fbe7c8158157e08b35f8255045d4476df694b91eb3a8147e65";
  };

  propagatedBuildInputs = [
    pythonPackages.py
  ];

  doCheck = false;

  meta = with stdenv.lib; {
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
