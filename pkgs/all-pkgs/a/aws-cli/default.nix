{ stdenv
, buildPythonPackage
, fetchzip

, botocore
, colorama
, docutils
, pyyaml
, rsa
, s3transfer
}:

let
  version = "1.11.21";
in
buildPythonPackage rec {
  name = "aws-cli-${version}";

  src = fetchzip {
    version = 2;
    url = "https://github.com/aws/aws-cli/archive/${version}.tar.gz";
    sha256 = "dab937778557d8b5797f246e13e5aabe8746fc3fe3dd9dadb9d19aead736b617";
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

  meta = with stdenv.lib; {
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
