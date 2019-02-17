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
  version = "1.16.106";
in
buildPythonPackage rec {
  name = "aws-cli-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "aws";
    repo = "aws-cli";
    rev = version;
    sha256 = "1c587c690b170107a850e81f6dde417e86099d3fbb0827b70d1fca16286656fd";
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
