{ stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchPyPi
, isPy3
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
  # https://docs.saltstack.com/en/latest/topics/releases/index.html
  # https://saltstack.com/product-support-lifecycle/
  sources = {
    "2016.11" = {
      version = "2016.11.6";
      sha256 = "9031af68d31d0416fe3161526ef122a763afc6182bd63fe48b6c4d0a16a0703a";
    };
    "2017.7" = {
      version = "2017.7.1";
      sha256 = "fe868415d0e1162157186f4c5263e9af902b0571870ad2da210e7edf5ff5331d";
    };
    head = {
      fetchzipversion = 2;
      version = "2017-02-17";
      rev = "deba6d26554720953409d2280e366621f40f5162";
      sha256 = "bcfd9417a3a37909c4835dc401d57d6eb3c90b89e30526f4e76bf8d7df177afd";
    };
  };
  source = sources."${channel}";
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

  disabled = isPy3;

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
