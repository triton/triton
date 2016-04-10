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
    sha256 = "4f2178ec975e3519b2be7848bcb4fc26d0b406c249fb4432f0672c925ca7fedf";
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
