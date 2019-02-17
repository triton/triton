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
  version = "2.7.7";
in
buildPythonPackage rec {
  name = "ansible-${version}";

  src = fetchPyPi {
    package = "ansible";
    inherit version;
    sha256 = "040cc936f959b947800ffaa5f940d2508aaa41f899efe56b47a7442c89689150";
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
