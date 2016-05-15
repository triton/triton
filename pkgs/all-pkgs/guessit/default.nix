{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "guessit-${version}";
  version = "2.0.5";

  src = fetchPyPi {
    package = "guessit";
    inherit version;
    sha256 = "626e0024c5cca9b84883b65246e4f238e3f39064664486f69f086c853a63ff61";
  };

  buildInputs = [
    pythonPackages.babelfish
    pythonPackages.dateutil
    pythonPackages.pytestrunner
    pythonPackages.rebulk
    pythonPackages.regex
  ];

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
