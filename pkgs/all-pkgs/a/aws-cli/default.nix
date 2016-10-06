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
  version = "1.11.1";
in
buildPythonPackage rec {
  name = "aws-cli-${version}";

  src = fetchzip {
    version = 2;
    url = "https://github.com/aws/aws-cli/archive/${version}.tar.gz";
    sha256 = "829a1409aae273e03219e934ce2d01e249602e29f998d899f1e13133a9d6ed7b";
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
