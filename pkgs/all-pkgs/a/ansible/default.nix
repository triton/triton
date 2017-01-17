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
  version = "2.2.1.0";
in
buildPythonPackage rec {
  name = "ansible-${version}";

  src = fetchPyPi {
    package = "ansible";
    inherit version;
    sha256 = "63a12ea784c0f90e43293b973d5c75263634c7415e463352846cd676c188e93f";
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
