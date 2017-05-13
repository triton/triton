{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cryptography
, ecdsa
, pyasn1
, pycrypto
, six
}:

let
  version = "2.1.2";
in
buildPythonPackage rec {
  name = "paramiko-${version}";

  src = fetchPyPi {
    package = "paramiko";
    inherit version;
    sha256 = "5fae49bed35e2e3d45c4f7b0db2d38b9ca626312d91119b3991d0ecf8125e310";
  };

  propagatedBuildInputs = [
    cryptography
    ecdsa
    pyasn1
    pycrypto
    six
  ];

  meta = with lib; {
    description = "Native Python SSHv2 protocol library";
    homepage = https://github.com/paramiko/paramiko/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
