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
  version = "2.4.1";
in
buildPythonPackage rec {
  name = "paramiko-${version}";

  src = fetchPyPi {
    package = "paramiko";
    inherit version;
    sha256 = "33e36775a6c71790ba7692a73f948b329cf9295a72b0102144b031114bd2a4f3";
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
