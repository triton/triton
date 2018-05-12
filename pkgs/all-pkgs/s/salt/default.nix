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
      version = "2016.11.9";
      sha256 = "272791eeb60b2135fef28c77791740945668f631ec2bfcb7163ed25bc09a8ab2";
    };
    "2017.7" = {
      version = "2017.7.5";
      sha256 = "d41ff6d5962361e92e926db8f24c5f2284817f9f78128b2546527258a3a2d8c6";
    };
      sha256 = "1d573095776ba052eec7d7cae1472f4b1d4c15f16e1d79c2dc48db3129dbae97";
    };
    head = {
      fetchzipversion = 5;
      version = "2018-03-01";
      rev = "7731ffae20b4ea5a140eb55aa7993f0ff3112c9d";
      sha256 = "54cc0d503f097507505f1822c9210513a454882d30130262ac0be0b55774ec3d";
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
