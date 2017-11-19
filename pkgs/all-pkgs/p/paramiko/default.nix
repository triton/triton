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
  version = "2.4.0";
in
buildPythonPackage rec {
  name = "paramiko-${version}";

  src = fetchPyPi {
    package = "paramiko";
    inherit version;
    sha256 = "486f637f0a33a4792e0e567be37426c287efaa8c4c4a45e3216f9ce7fd70b1fc";
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
