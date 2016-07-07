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
  name = "sydent-2016-07-05";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "sydent";
    rev = "f2c5d5fda430f7f1f22105cd89d6e5bcd432e5f1";
    sha256 = "a78754c869c4e1e8413217eb0bef921e0384038fd125c91f502c43308dc30146";
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
