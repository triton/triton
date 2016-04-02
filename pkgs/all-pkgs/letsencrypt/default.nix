{ stdenv
, fetchFromGitHub
, pythonPackages
}:

pythonPackages.buildPythonPackage rec {
  name = "letsencrypt-${version}";
  version = "0.4.2";
  
  src = fetchFromGitHub {
    owner = "letsencrypt";
    repo = "letsencrypt";
    rev = "v${version}";
    sha256 = "7f5509bf42e6ee9a3e1619ebbe7a7528bdb025e96eccddaaa9d94fe7d4f31b41";
  };
  
  pythonPath = with pythonPackages; [
    acme
    ConfigArgParse
    configobj
    cryptography
    parsedatetime
    psutil
    pyopenssl
    python2-pythondialog
    pyRFC3339
    pytz
    six
    zope_component
    zope_interface
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
