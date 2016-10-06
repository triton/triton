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
  name = "sydent-2016-09-20";

  src = fetchFromGitHub {
    version = 2;
    owner = "matrix-org";
    repo = "sydent";
    rev = "0d0dba43a469986d31ece161044cd9c5875c519d";
    sha256 = "408187bebcd13388c91a6a4e208954936317f72e65d9ea1e8ea88176584a1b16";
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
