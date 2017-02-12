{ stdenv
, buildPythonPackage
, fetchzip
, lib

, botocore
, colorama
, docutils
, pyyaml
, rsa
, s3transfer
}:

let
  version = "1.11.47";
in
buildPythonPackage rec {
  name = "aws-cli-${version}";

  src = fetchzip {
    version = 2;
    url = "https://github.com/aws/aws-cli/archive/${version}.tar.gz";
    sha256 = "5bffcc09734471f7a8a5c8fd3b05b174ea9eba6d4d176c270bdead316780fc19";
  };

  propagatedBuildInputs = [
    botocore
    colorama
    docutils
    pyyaml
    rsa
    s3transfer
  ];

  postInstall = ''
    rm -f "$out"/bin/{aws.cmd,aws_completer,aws_bash_completer,aws_zsh_completer.sh}
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
