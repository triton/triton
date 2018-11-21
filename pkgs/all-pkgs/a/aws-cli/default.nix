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
  version = "1.16.57";
in
buildPythonPackage rec {
  name = "aws-cli-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "aws";
    repo = "aws-cli";
    rev = version;
    sha256 = "c9a1c13d3fdffbd06d4e256741794a7f4793023eb588f6e88846ea9f02522556";
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
