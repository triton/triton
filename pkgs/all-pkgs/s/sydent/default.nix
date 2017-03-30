{ stdenv
, buildPythonPackage
, fetchFromGitHub

, daemonize
, funcsigs
, mock
, pathlib2
, pbr
, phonenumbers
, pyasn1
, pynacl
, service-identity
, setuptools-trial
, signedjson
, six
, twisted
, unpaddedbase64
}:

buildPythonPackage {
  name = "sydent-2017-03-30";

  src = fetchFromGitHub {
    version = 2;
    owner = "matrix-org";
    repo = "sydent";
    rev = "bef1fa512897d60883e8b055169a0e3486216e55";
    sha256 = "af62a07330cbb1d1ccaccf2a5933cfc6025df5d6f3413309203f7f01008a6193";
  };

  buildInputs = [
    mock
  ];

  propagatedBuildInputs = [
    daemonize
    funcsigs
    pathlib2
    pbr
    phonenumbers
    pyasn1
    pynacl
    service-identity
    setuptools-trial
    signedjson
    six
    twisted
    unpaddedbase64
  ];

  postInstall = ''
    mkdir -p $out/bin
    echo '#!/bin/sh' >> "$out/bin/sydent"
    echo "export PYTHONPATH='$PYTHONPATH'" >> "$out/bin/sydent"
    echo "$(command -v python) -m sydent.sydent \"\$@\"" >> "$out/bin/sydent"
    chmod +x "$out/bin/sydent"
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
