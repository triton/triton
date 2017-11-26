{ stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchPyPi
, isPy2
, isPy3
, lib
, python

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

# NOTE:
# - Modules distributed with salt that require third-party modules or other
#   external commands are not supported by this build.  It is recommeneded
#   that you distribute the modules via salt.utils.sync_* methods by your
#   own means.  Most of the modules would require significat patching and
#   would add hundreds of dependencies to this build to make them work.
#   This way there are no silent failures and salt will return an explicit
#   error that the requested module does not exist.  This leaves a minimal
#   salt build with only core functionality.  Anything that cannot be
#   configured by the user however has been left in place and may break at
#   runtime (e.g. auth/cache/config/fileserver/queues/runners).

# FIXME: unvendor salt/ext/* modules.

let
  inherit (lib)
    optionals;

  # https://docs.saltstack.com/en/latest/topics/releases/index.html
  # https://saltstack.com/product-support-lifecycle/
  sources = {
    "2016.11" = {
      version = "2016.11.8";
      sha256 = "e75f4178465d9198fcd5822643460c94d63de6221316367d5b85356ef8b1994a";
    };
    "2017.7" = {
      version = "2017.7.2";
      sha256 = "ff3bc7de5abf01b8acbd144db5811b00867179b2353f5c6f7f19241e2eff2840";
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
  '' + /* Remove third-party modules, see note above */ ''
    ${python.interpreter} ${./remove-modules.py}
  '' + /* _property_entry_points are clobbering _property_scripts */ ''
    sed -i setup.py \
      -e '/salt.scripts:salt_unity/d'
  '';

  propagatedBuildInputs = /* Required */ ([
    jinja2
    markupsafe
    msgpack-python
    pyyaml
    requests
    tornado
  ] ++ optionals isPy2 [
    futures
  ]) ++ /* ZeroMQ */ [
    pycrypto
    pyzmq
  ] ++ /* Raet */ [  # TODO
    # ioflo
    # libnacl
    # raet
  ] ++ /* Optional */ [
    cherrypy
    #libnacl
    #mysql-python
    #python-gnupg
    #python-novaclient
    #python-neutronclient
    #timelib
    #yappi
  ];

  checkPhase = /* Basic test to make sure we have necessary modules */ ''
    for i in $out/bin/s*; do
      $i -h >/dev/null
    done
  '';

  doCheck = true;

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
