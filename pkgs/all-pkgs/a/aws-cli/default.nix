{ stdenv
, buildPythonPackage
, fetchzip

, botocore
, colorama
, docutils
, rsa
, s3transfer
}:

let
  version = "1.10.63";
in
buildPythonPackage rec {
  name = "aws-cli-${version}";

  src = fetchzip {
    version = 2;
    url = "https://github.com/aws/aws-cli/archive/${version}.tar.gz";
    sha256 = "f793c65e24a8ad04a4fc897c938369293960836d7a8faf8f5a366fbd30bd213f";
  };

  propagatedBuildInputs = [
    botocore
    colorama
    docutils
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
