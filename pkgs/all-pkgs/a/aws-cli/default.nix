{ stdenv
, buildPythonPackage
, fetchFromGitHub
, lib

, botocore
, colorama
, docutils
, pyasn1
, pyyaml
, rsa
, s3transfer
}:

let
  version = "1.16.52";
in
buildPythonPackage rec {
  name = "aws-cli-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "aws";
    repo = "aws-cli";
    rev = version;
    sha256 = "0cc559a4db8b396dcb6d3d55a20a3b76efbe7ff8f074cf33a5e7659cbecefc52";
  };

  propagatedBuildInputs = [
    botocore
    colorama
    docutils
    pyasn1
    pyyaml
    rsa
    s3transfer
  ];

  # Remove examples
  postInstall = ''
    find "$out" -name examples -exec rm -rv {} \; -prune
  '';

  meta = with lib; {
    description = "Command Line Interface for Amazon Web Services";
    homepage = https://github.com/aws/aws-cli;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
