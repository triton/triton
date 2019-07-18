{ stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchPyPi
, lib

, babelfish
, pytest-runner
, python-dateutil
, rebulk

, channel ? "stable"
}:

let
  inherit (lib)
    optionals;

  sources = {
    stable = {
      version = "3.0.4";
      sha256 = "37803ec0d7f20f2e1425dfe3bb978dc3b9c65872aa3760c664b31a9115232ec1";
    };
    head = {
      fetchzipversion = 6;
      version = "2018-10-23";
      rev = "5c2cfeee519f3027588a5f5afafc5eb22ffbd439";
      sha256 = "34c42efa4d1e04bb4ccac9d63ce02fcdbd7324c098d284771f6d1fbfea1302a7";
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

  propagatedBuildInputs = [
    babelfish
    pytest-runner
    python-dateutil
    rebulk
  ];

  meta = with lib; {
    description = "A library for guessing information from video filenames";
    homepage = https://github.com/guessit-io/guessit;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
