{ stdenv
, buildPythonPackage
, fetchPyPi

, babelfish
, pytestrunner
, python-dateutil
, rebulk
, regex

, pytest
, pytest-benchmark
, pytest-capturelog
, pyyaml
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "2.1.0";
in
buildPythonPackage rec {
  name = "guessit-${version}";

  src = fetchPyPi {
    package = "guessit";
    inherit version;
    sha256 = "a534a46bef3bbac7b313a55744860a9ddd5b7fae6abb6f6ae8bbace2b3e973b1";
  };

  buildInputs = optionals doCheck [
    pytest
    pytest-benchmark
    pytest-capturelog
    pyyaml
  ];

  propagatedBuildInputs = [
    babelfish
    pytestrunner
    python-dateutil
    rebulk
    regex
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
