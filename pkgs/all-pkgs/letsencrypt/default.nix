{ stdenv
, fetchFromGitHub
, pythonPackages

, dialog
}:

pythonPackages.buildPythonPackage rec {
  name = "letsencrypt-${version}";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "letsencrypt";
    repo = "letsencrypt";
    rev = "v${version}";
    sha256 = "d1941faa21109f452d1d4e58cb6015b6bc8b188aa00a6f71191840f0b38ec302";
  };

  pythonPath = with pythonPackages; [
    acme
    ConfigArgParse
    configobj
    cryptography
    dialog
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
