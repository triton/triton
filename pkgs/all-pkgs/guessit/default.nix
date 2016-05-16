{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
in

buildPythonPackage rec {
  name = "guessit-${version}";
  version = "2.0.5";

  src = fetchPyPi {
    package = "guessit";
    inherit version;
    sha256 = "626e0024c5cca9b84883b65246e4f238e3f39064664486f69f086c853a63ff61";
  };

  postPatch = ''
    sed -i setup.py \
      -e 's/python-dateutil<2.5.2/python-dateutil>=2.5.2/'
  '';

  buildInputs = [
    pythonPackages.babelfish
    pythonPackages.pytestrunner
    pythonPackages.python-dateutil
    pythonPackages.rebulk
    pythonPackages.regex
  ] ++ optionals doCheck [
    pythonPackages.pytest
    pythonPackages.pytest-benchmark
    pythonPackages.pytest-capturelog
    pythonPackages.pyyaml
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "A library for guessing information from video filenames";
    homepage = https://pypi.python.org/pypi/guessit;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
