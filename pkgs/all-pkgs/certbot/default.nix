{ stdenv
, buildPythonPackage
, fetchFromGitHub

, pkgs
, pythonPackages
}:

let
  inherit (pythonPackages)
    isPy3k;
in

buildPythonPackage rec {
  name = "certbot-${version}";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "certbot";
    repo = "certbot";
    rev = "v${version}";
    sha256 = "d3edc6764d4e7ef61e9788e887ae6088422199db4c1a3559e0304983b41c70a4";
  };

  pythonPath = [
    pkgs.dialog
    pythonPackages.acme
    pythonPackages.ConfigArgParse
    pythonPackages.configobj
    pythonPackages.cryptography
    pythonPackages.parsedatetime
    pythonPackages.psutil
    pythonPackages.pyopenssl
    pythonPackages.python2-pythondialog
    pythonPackages.pyRFC3339
    pythonPackages.pytz
    pythonPackages.six
    pythonPackages.zope-component
    pythonPackages.zope-interface
  ];

  disabled = isPy3k;
  doCheck = true;

  meta = with stdenv.lib; {
    description = "EFF's tool to obtain certs from Let's Encrypt";
    homepage = https://github.com/certbot/certbot;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
