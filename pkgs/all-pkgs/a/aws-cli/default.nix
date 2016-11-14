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
  version = "1.11.14";
in
buildPythonPackage rec {
  name = "aws-cli-${version}";

  src = fetchzip {
    version = 2;
    url = "https://github.com/aws/aws-cli/archive/${version}.tar.gz";
    sha256 = "2132be5b344355f84ba3d1c207305f620c12e5f73588d5a59187a71083f99369";
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
