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
  name = "sydent-2016-06-03";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "sydent";
    rev = "93a49497f8cad02ad0553911b60cfa0c5253ddb3";
    sha256 = "0e10a3ef8528f636041f5838440553155b0f6584f0f33311c8faef0d7980c4a4";
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

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
