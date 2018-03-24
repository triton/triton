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
  version = "2.5.0";
in
buildPythonPackage rec {
  name = "ansible-${version}";

  src = fetchPyPi {
    package = "ansible";
    inherit version;
    sha256 = "0e98b3a56928d03979d5f8e7ae5d8e326939111b298729b03f00b3ad8f998a3d";
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
