{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, babelfish
, pytest-runner
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

  version = "2.1.4";
in
buildPythonPackage rec {
  name = "guessit-${version}";

  src = fetchPyPi {
    package = "guessit";
    inherit version;
    sha256 = "90e6f9fb49246ad27f34f8b9984357e22562ccc3059241cbc08b4fac1d401c56";
  };

  nativeBuildInputs = optionals doCheck [
    pytest
    pytest-benchmark
    pytest-capturelog
    pyyaml
  ];

  propagatedBuildInputs = [
    babelfish
    pytest-runner
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
