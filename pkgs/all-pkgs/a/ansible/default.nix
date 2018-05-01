{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

#, httplib2
, jinja2
, netaddr
, paramiko
#, passlib
, pycrypto
, pyyaml
, six
#, ssh
#, sshpass
}:

let
  version = "2.5.2";
in
buildPythonPackage rec {
  name = "ansible-${version}";

  src = fetchPyPi {
    package = "ansible";
    inherit version;
    sha256 = "a95483f3b33e0f97d03badaad073392ed03a2b2f526bec4ddf598edfc1c03ae5";
  };

  propagatedBuildInputs = [
    #httplib2
    jinja2
    #keyczar
    netaddr
    paramiko
    #passlib
    pycrypto
    pyyaml
    six
    #ssh
    #sshpass
  ];

  meta = with lib; {
    description = "Deployment, config management, & command execution framework";
    homepage = http://ansible.com/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
