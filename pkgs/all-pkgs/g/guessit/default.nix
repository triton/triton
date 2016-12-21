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

  version = "2.1.1";
in
buildPythonPackage rec {
  name = "guessit-${version}";

  src = fetchPyPi {
    package = "guessit";
    inherit version;
    sha256 = "cdb51ced109e05318f35dc5ee1c50182a85edd800e86de77ec96eb68a0a99391";
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
