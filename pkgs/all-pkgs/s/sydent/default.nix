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

let
  date = "2017-04-25";
  rev = "3d3ac5ab802ad91bbecfc0cd6a50bdd31875c1fe";
in
buildPythonPackage {
  name = "sydent-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "matrix-org";
    repo = "sydent";
    inherit rev;
    sha256 = "0912dcbde9a772299d5080eb60e5d24667410c04c5198253d2cf0c79858d7a0c";
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
