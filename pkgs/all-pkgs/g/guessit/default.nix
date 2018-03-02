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
      version = "2018-02-12";
      rev = "3afb850be95698a46f1c878be408ddf7f671b408";
      sha256 = "48c02fa6346096b51175aeda5444369867716a896161e2f84cc2976b77e9b3f0";
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
