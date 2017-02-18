{ stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchPyPi
, isPy3k
, lib

, apache-libcloud
, cherrypy
#, dnspython
, futures
#, ioflo
, jinja2
#, keyring
#, libnacl
#, libvirt-python
#, m2crypto
, Mako
, markupsafe
, msgpack-python
#, mysql-python
, netaddr
, openssl
, pycrypto
#, pygit2
, pymongo
, pyopenssl
, python-dateutil
#, python-gnupg
, python-ldap
#, python-neutronclient
#, python-novaclient
, pyyaml
, pyzmq
#, raet
#, redis-py
, requests
#, salt-vim
#, selinux-salt
#, systemd
#, timelib
, tornado
#, yappi

, channel
}:

let
  source = (import ./sources.nix { })."${channel}";
in
buildPythonPackage rec {
  name = "salt-${source.version}";

  src =
    if channel != "head" then
      fetchPyPi {
        package = "salt";
        inherit (source) version sha256;
      }
    else
      fetchFromGitHub {
        version = source.fetchzipversion;
        owner = "saltstack";
        repo = "salt";
        inherit (source) rev sha256;
      };

  postPatch = /* Salt looks for openssl in salt's installation prefix */ ''
    sed -i salt/utils/rsax931.py \
      -e "s,find_library('crypto'),'${openssl}/lib/libcrypto.so',"
  '';

  propagatedBuildInputs = [
    apache-libcloud
    cherrypy
    #dnspython  # states/Network NTP
    futures
    #ioflo  # Salt RAET transport
    jinja2
    #keyring
    #libnacl  # Salt RAET transport
    #libvirt-python
    #m2crypto
    Mako  # states parser
    markupsafe
    msgpack-python
    #mysql-python
    netaddr  # states/Network NTP
    openssl
    pycrypto  # Salt ZeroMQ transport
    #pygit2
    pymongo  # states/Mongodb Users
    pyopenssl
    #python-croniter  # states/Scheduler
    python-dateutil  # states/Scheduler
    #python-gnupg  # states/Pkg repos (APT/YUM)
    python-ldap
    #python-neutronclient
    #python-novaclient
    pyyaml
    pyzmq  # Salt ZeroMQ transport
    #raet  # Salt RAET transport
    #redis-py
    requests
    #salt-vim
    #selinux-salt
    #systemd
    #timelib
    tornado
    #yappi
  ];

  disabled = isPy3k;

  meta = with lib; {
    description = "Distributed, remote execution & configuration management system";
    homepage = http://saltstack.org/;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
