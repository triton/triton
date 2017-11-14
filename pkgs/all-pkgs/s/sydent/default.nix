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
  date = "2017-11-11";
  rev = "c3879957b0b7a1e3509f8b727a66bcef4a8cd0c2";
in
buildPythonPackage {
  name = "sydent-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "matrix-org";
    repo = "sydent";
    inherit rev;
    sha256 = "a82d403bda0f7e880b6ac7651ca8730b4745818b76a850c24b365bc7544b43f9";
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
