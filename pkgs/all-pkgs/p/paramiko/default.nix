{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, bcrypt
, cryptography
, ecdsa
, pyasn1
, pycrypto
, pynacl
, six
}:

let
  version = "2.2.1";
in
buildPythonPackage rec {
  name = "paramiko-${version}";

  src = fetchPyPi {
    package = "paramiko";
    inherit version;
    sha256 = "ff94ae65379914ec3c960de731381f49092057b6dd1d24d18842ead5a2eb2277";
  };

  propagatedBuildInputs = [
    bcrypt
    cryptography
    ecdsa
    pyasn1
    pycrypto
    pynacl
    six
  ];

  meta = with lib; {
    description = "Native Python SSHv2 protocol library";
    homepage = https://github.com/paramiko/paramiko/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
