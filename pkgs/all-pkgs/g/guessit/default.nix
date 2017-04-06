{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

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
  inherit (lib)
    optionals;

  version = "2.1.2";
in
buildPythonPackage rec {
  name = "guessit-${version}";

  src = fetchPyPi {
    package = "guessit";
    inherit version;
    sha256 = "9f7e12b7f2215548284631a20aae6fc009c8af2bb8cc5d5e5e339cb15361dd95";
  };

  nativeBuildInputs = optionals doCheck [
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

  meta = with lib; {
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
