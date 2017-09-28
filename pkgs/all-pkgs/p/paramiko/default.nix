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
  version = "2.3.1";
in
buildPythonPackage rec {
  name = "paramiko-${version}";

  src = fetchPyPi {
    package = "paramiko";
    inherit version;
    sha256 = "fa6b4f5c9d88f27c60fd9578146ff24e99d4b9f63391ff1343305bfd766c4660";
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
