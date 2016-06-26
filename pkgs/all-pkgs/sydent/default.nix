{ stdenv
, buildPythonPackage
, fetchFromGitHub

, daemonize
, funcsigs
, pathlib2
, pbr
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
  name = "sydent-2016-06-20";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "sydent";
    rev = "c4e160488f4758b7f260225631f2cdc1812b9b9a";
    sha256 = "5d155088b2b7c614654d024b808c2f9c6f0ff6fc682344f0a9667d366aba9a8f";
  };

  propagatedBuildInputs = [
    daemonize
    funcsigs
    pathlib2
    pbr
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
