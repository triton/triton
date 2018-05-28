{ stdenv
, buildPythonPackage
, fetchFromGitHub
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

, channel ? "head"
}:

let
  inherit (lib)
    optionals;

  sources = {
    "stable" = {
      version = "2.1.4";
      sha256 = "90e6f9fb49246ad27f34f8b9984357e22562ccc3059241cbc08b4fac1d401c56";
    };
    head = {
      fetchzipversion = 5;
      version = "2018-05-21";
      rev = "a54e8acdd37ba3fac2be3c651e2d22f8742608c6";
      sha256 = "01a35a128d6e58251f98018d5dbe5eabb91b1370c0f74c869906e4bd4a3fa205";
    };
  };
  source = sources."${channel}";
in
buildPythonPackage rec {
  name = "guessit-${source.version}";

  src =
    if channel != "head" then
      fetchPyPi {
        package = "guessit";
        inherit (source) sha256 version;
      }
    else
      fetchFromGitHub {
        version = source.fetchzipversion;
        owner = "guessit-io";
        repo = "guessit";
        inherit (source) rev sha256;
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
