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
    sha256 = "8559646fd7691a5a5078094428a2d17a3b333755e0fe94031f42a1c5a7b33800";
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
