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
  version = "2.3.2.0";
in
buildPythonPackage rec {
  name = "ansible-${version}";

  src = fetchPyPi {
    package = "ansible";
    inherit version;
    sha256 = "0563b425279422487f12616ef719f6e558373b258dcf47e548d119be8d3168eb";
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
