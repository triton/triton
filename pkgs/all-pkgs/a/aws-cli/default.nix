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
  version = "1.10.65";
in
buildPythonPackage rec {
  name = "aws-cli-${version}";

  src = fetchzip {
    version = 2;
    url = "https://github.com/aws/aws-cli/archive/${version}.tar.gz";
    sha256 = "dee96102358046fcbb0d00c36e1de2cb5007c26dd181779f3258d3133794933a";
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
