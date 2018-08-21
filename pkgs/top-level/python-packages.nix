{ pkgs
, python
, self
, stdenv

, newBootstrap ? false
}:

with pkgs.lib;

let
  # DEPRECATED: Use python.<func> instead
  pythonAtLeast = python.pythonAtLeast;
  pythonOlder = python.pythonOlder;
  isPy2 = python.isPy2;
  isPy3 = python.isPy3;
  isPyPy = python.isPyPy;

  fetchPyPi = { package, version, sha256, type ? ".tar.gz" }:
    pkgs.fetchurl rec {
      name = "${package}-${version}${type}";
      url = "https://localhost/not-a-url";
      fullOpts = {
        preFetch = ''
          $curl 'https://pypi.org/pypi/${package}/json' | \
            ${pkgs.jq}/bin/jq -r '
              .releases["${version}"] |
                reduce .[] as $item ("";
                  if $item.filename == "${name}" then
                    $item.url
                  else
                    .
                  end)
            ' > "$TMPDIR/url"
          urls=($(cat "$TMPDIR/url"))
        '';
      };
      inherit sha256;
    };

  # Stage 1 pkgs, builds wheel dists
  buildBootstrapPythonPackage = makeOverridable (
    callPackage ../all-pkgs/b/build-python-package rec {
      stage = 1;
      namePrefix = python.libPrefix + "-stage1-";

      # Stage 0 pkgs, builds basic egg dists
      appdirs = callPackage ../all-pkgs/a/appdirs/bootstrap.nix { };
      packaging = callPackage ../all-pkgs/p/packaging/bootstrap.nix {
        inherit
          pyparsing
          six;
      };
      pip = callPackage ../all-pkgs/p/pip/bootstrap.nix {
        inherit
          setuptools;
      };
      pyparsing = callPackage ../all-pkgs/p/pyparsing/bootstrap.nix { };
      setuptools = callPackage ../all-pkgs/s/setuptools/bootstrap.nix {
        inherit
          appdirs
          packaging
          pyparsing
          six;
      };
      six = callPackage ../all-pkgs/s/six/bootstrap.nix { };
      wheel = callPackage ../all-pkgs/w/wheel/bootstrap.nix {
        inherit
          setuptools;
      };
    }
  );

  # Stage 2 pkgs, builds final wheel dists
  buildPythonPackage = makeOverridable (
    callPackage ../all-pkgs/b/build-python-package rec {
      stage = 2;
      inherit (self)
        packaging
        pip
        pyparsing
        # setuptools
        six
        wheel;
      # Upstream setuptools bug breaks namespaced packages when install to
      # a wheel dist from a wheel dist.
      # Upstream fix for installing to an egg dist from a wheel.
      # https://github.com/pypa/setuptools/commit/b9df5fd4d08347b9db0e486af43d08978cb9f4bc
      setuptools =
        if newBootstrap == true then
          self.setuptools
        else
          callPackage ../all-pkgs/s/setuptools/bootstrap.nix { };
    }
  );

  callPackage = pkgs.newScope (self // {
    inherit pkgs;
    pythonPackages = self;
  });

  callPackageAlias = package: newAttrs: self."${package}".override newAttrs;

in {

  inherit
    buildBootstrapPythonPackage
    buildPythonPackage
    fetchPyPi
    isPy2
    isPyPy
    isPy3
    python
    pythonAtLeast
    pythonOlder;

  # helpers

  wrapPython = pkgs.makeSetupHook {
    deps = pkgs.makeWrapper;
    substitutions.libPrefix = python.libPrefix;
    substitutions.executable = python.interpreter;
    substitutions.magicalSedExpression =
      let
        # Looks weird? Of course, it's between single quoted shell strings.
        # NOTE: Order DOES matter here, so single character quotes need to be
        #       at the last position.
        quoteVariants = [
          "'\"'''\"'"
          "\"\"\""
          "\""
          "'\"'\"'"
        ];

        mkStringSkipper =
          labelNum: quote:
          let
            label = "q${toString labelNum}";
            isSingle = elem quote [ "\"" "'\"'\"'" ];
            endQuote = if isSingle then "[^\\\\]${quote}" else quote;
          in ''
            /^ *[a-z]?${quote}/ {
              /${quote}${quote}|${quote}.*${endQuote}/{n;br}
              :${label}; n; /^${quote}/{n;br}; /${endQuote}/{n;br}; b${label}
            }
          '';
      in ''
        1 {
          /^#!/!b; :r
          /\\$/{N;br}
          /__future__|^ *(#.*)?$/{n;br}
          ${concatImapStrings mkStringSkipper quoteVariants}
          /^ *[^# ]/i import sys; sys.argv[0] = '"'$(basename "$f")'"'
        }
      '';
  } ../all-pkgs/b/build-python-package/wrap.sh;

  # specials

  recursivePthLoader = callPackage ../all-pkgs/r/recursive-pth-loader { };

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
############################### BEGIN ALL PKGS #################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

acd-cli = callPackage ../all-pkgs/a/acd-cli { };

affinity = callPackage ../all-pkgs/a/affinity { };

alabaster = callPackage ../all-pkgs/a/alabaster { };

aniso8601 = callPackage ../all-pkgs/a/aniso8601 { };

ansible = callPackage ../all-pkgs/a/ansible { };

apache-libcloud = callPackage ../all-pkgs/a/apache-libcloud { };

appdirs = callPackage ../all-pkgs/a/appdirs {
  buildPythonPackage = self.buildBootstrapPythonPackage;
};

apscheduler = callPackage ../all-pkgs/a/apscheduler { };

asciinema = callPackage ../all-pkgs/a/asciinema { };

asn1crypto = callPackage ../all-pkgs/a/asn1crypto { };

astroid = callPackage ../all-pkgs/a/astroid { };

attrs = callPackage ../all-pkgs/a/attrs { };

automat = callPackage ../all-pkgs/a/automat { };

autotorrent = callPackage ../all-pkgs/a/autotorrent { };

aws-cli = callPackage ../all-pkgs/a/aws-cli { };

babel = callPackage ../all-pkgs/b/babel { };

babelfish = callPackage ../all-pkgs/b/babelfish { };

backports-abc = callPackage ../all-pkgs/b/backports-abc { };

backports-ssl-match-hostname =
  callPackage ../all-pkgs/b/backports-ssl-match-hostname { };

bazaar = callPackage ../all-pkgs/b/bazaar { };

bcrypt = callPackage ../all-pkgs/b/bcrypt { };

beautifulsoup = callPackage ../all-pkgs/b/beautifulsoup { };

beets = callPackage ../all-pkgs/b/beets {
  channel = "stable";
};
beets_head = callPackage ../all-pkgs/b/beets {
  channel = "head";
};

bleach = callPackage ../all-pkgs/b/bleach { };

blist = callPackage ../all-pkgs/b/blist { };

borgbackup = callPackage ../all-pkgs/b/borgbackup { };

borgmatic = callPackage ../all-pkgs/b/borgmatic { };

botocore = callPackage ../all-pkgs/b/botocore { };

brotli = callPackage ../all-pkgs/b/brotli/python.nix {
  brotli = pkgs.brotli;
};

bzrtools = callPackage ../all-pkgs/b/bzrtools { };

canonicaljson = callPackage ../all-pkgs/c/canonicaljson { };

certbot = callPackage ../all-pkgs/c/certbot { };

certifi = callPackage ../all-pkgs/c/certifi { };

cffi = callPackage ../all-pkgs/c/cffi { };

characteristic = callPackage ../all-pkgs/c/characteristic { };

chardet = callPackage ../all-pkgs/c/chardet { };

cheetah = callPackage ../all-pkgs/c/cheetah { };

cheroot = callPackage ../all-pkgs/c/cheroot { };

cherrypy = callPackage ../all-pkgs/c/cherrypy { };

click = callPackage ../all-pkgs/c/click { };

colorama = callPackage ../all-pkgs/c/colorama { };

colorclass = callPackage ../all-pkgs/c/colorclass { };

configparser = callPackage ../all-pkgs/c/configparser { };

constantly = callPackage ../all-pkgs/c/constantly { };

cryptography = callPackage ../all-pkgs/c/cryptography { };

cryptography-vectors = callPackage ../all-pkgs/c/cryptography-vectors { };

cvs2svn = callPackage ../all-pkgs/c/cvs2svn { };

cython = callPackage ../all-pkgs/c/cython { };

daemonize = callPackage ../all-pkgs/d/daemonize { };

dbus-python = callPackage ../all-pkgs/d/dbus-python { };

debtcollector = callPackage ../all-pkgs/d/debtcollector { };

decorator = callPackage ../all-pkgs/d/decorator { };

defusedxml = callPackage ../all-pkgs/d/defusedxml { };

deluge = callPackage ../all-pkgs/d/deluge {
  channel = "stable";
};
deluge_head = callPackage ../all-pkgs/d/deluge {
  channel = "head";
};

deluge-client = callPackage ../all-pkgs/d/deluge-client { };

diffoscope = callPackage ../all-pkgs/d/diffoscope { };

discogs-client = callPackage ../all-pkgs/d/discogs-client { };

dnsdiag = callPackage ../all-pkgs/d/dnsdiag { };

dnspython = callPackage ../all-pkgs/d/dnspython { };

docopt = callPackage ../all-pkgs/d/docopt { };

docutils = callPackage ../all-pkgs/d/docutils { };

duplicity = callPackage ../all-pkgs/d/duplicity { };

enum34 = callPackage ../all-pkgs/e/enum34 { };

etcd = callPackage ../all-pkgs/e/etcd { };

fasteners = callPackage ../all-pkgs/f/fasteners { };

fido2 = callPackage ../all-pkgs/f/fido2 { };

flask = callPackage ../all-pkgs/f/flask { };

flask-compress = callPackage ../all-pkgs/f/flask-compress { };

flask-login = callPackage ../all-pkgs/f/flask-login { };

flask-restful = callPackage ../all-pkgs/f/flask-restful { };

flask-restplus_0-8 = callPackage ../all-pkgs/f/flask-restplus {
  channel = "0.8";
};
flask-restplus = callPackage ../all-pkgs/f/flask-restplus { };

flexget = callPackage ../all-pkgs/f/flexget { };

fonttools = callPackage ../all-pkgs/f/fonttools { };

foolscap = callPackage ../all-pkgs/f/foolscap { };

frozendict = callPackage ../all-pkgs/f/frozendict { };

funcsigs = callPackage ../all-pkgs/f/funcsigs { };

functools32 = callPackage ../all-pkgs/f/functools32 { };

fusepy = callPackage ../all-pkgs/f/fusepy { };

future = callPackage ../all-pkgs/f/future { };

futures = callPackage ../all-pkgs/f/futures { };

gevent = callPackage ../all-pkgs/g/gevent { };

greenlet = callPackage ../all-pkgs/g/greenlet { };

gst-python_1-14 = callPackage ../all-pkgs/g/gst-python {
  channel = "1.14";
  gst-plugins-base = pkgs.gst-plugins-base_1-14;
  gstreamer = pkgs.gstreamer_1-14;
};
gst-python = callPackageAlias "gst-python_1-14" { };

guessit = callPackage ../all-pkgs/g/guessit { };

html5lib = callPackage ../all-pkgs/h/html5lib { };

hyperlink = callPackage ../all-pkgs/h/hyperlink { };

idna = callPackage ../all-pkgs/i/idna { };

incremental = callPackage ../all-pkgs/i/incremental { };

iotop = callPackage ../all-pkgs/i/iotop { };

imagesize = callPackage ../all-pkgs/i/imagesize { };

ip-associations-python-novaclient-ext =
  callPackage ../all-pkgs/i/ip-associations-python-novaclient-ext { };

ipaddress = callPackage ../all-pkgs/i/ipaddress { };

iso8601 = callPackage ../all-pkgs/i/iso8601 { };

isort = callPackage ../all-pkgs/i/isort { };

itstool = callPackage ../all-pkgs/i/itstool { };

jaraco-classes = callPackage ../all-pkgs/j/jaraco-classes { };

jinja2 = callPackage ../all-pkgs/j/jinja2 { };

jmespath = callPackage ../all-pkgs/j/jmespath { };

jsonschema = callPackage ../all-pkgs/j/jsonschema { };

keyring = callPackage ../all-pkgs/k/keyring { };

keystoneauth1 = callPackage ../all-pkgs/k/keystoneauth1 { };

lazy-object-proxy = callPackage ../all-pkgs/l/lazy-object-proxy { };

ldap3 = callPackage ../all-pkgs/l/ldap3 { };

libarchive-c = callPackage ../all-pkgs/l/libarchive-c { };

llfuse = callPackage ../all-pkgs/l/llfuse { };

lockfile = callPackage ../all-pkgs/l/lockfile { };

lxml = callPackage ../all-pkgs/l/lxml { };

libxml2 = callPackage ../all-pkgs/l/libxml2/python.nix {
  libxml2 = pkgs.libxml2;
};

m2crypto = callPackage ../all-pkgs/m/m2crypto { };

m2r = callPackage ../all-pkgs/m/m2r { };

mako = callPackage ../all-pkgs/m/mako { };
Mako = callPackageAlias "mako" { };  # DEPRECATED

markupsafe = callPackage ../all-pkgs/m/markupsafe { };

matrix-angular-sdk = callPackage ../all-pkgs/m/matrix-angular-sdk { };

matrix-synapse-ldap3 = callPackage ../all-pkgs/m/matrix-synapse-ldap3 { };

mccabe = callPackage ../all-pkgs/m/mccabe { };

meson = callPackage ../all-pkgs/m/meson { };

mercurial = callPackage ../all-pkgs/m/mercurial { };

mistune = callPackage ../all-pkgs/m/mistune { };

monotonic = callPackage ../all-pkgs/m/monotonic { };

mopidy = callPackage ../all-pkgs/m/mopidy { };

msgpack-python = callPackage ../all-pkgs/m/msgpack-python { };

mutagen = callPackage ../all-pkgs/m/mutagen { };

netaddr = callPackage ../all-pkgs/n/netaddr { };

netifaces = callPackage ../all-pkgs/n/netifaces { };

nevow = callPackage ../all-pkgs/n/nevow { };

notify-python = callPackage ../all-pkgs/n/notify-python { };

oauthlib = callPackage ../all-pkgs/o/oauthlib { };

olefile = callPackage ../all-pkgs/o/olefile { };

os-diskconfig-python-novaclient-ext =
  callPackage ../all-pkgs/o/os-diskconfig-python-novaclient-ext { };

os-networksv2-python-novaclient-ext =
  callPackage ../all-pkgs/o/os-networksv2-python-novaclient-ext { };

os-virtual-interfacesv2-python-novaclient-ext =
  callPackage ../all-pkgs/o/os-virtual-interfacesv2-python-novaclient-ext { };

oslo-i18n = callPackage ../all-pkgs/o/oslo-i18n { };

oslo-serialization = callPackage ../all-pkgs/o/oslo-serialization { };

oslo-utils = callPackage ../all-pkgs/o/oslo-utils { };

packaging = callPackage ../all-pkgs/p/packaging {
  buildPythonPackage = self.buildBootstrapPythonPackage;
  inherit (self)
    pyparsing
    six;
};

paramiko = callPackage ../all-pkgs/p/paramiko { };

paste = callPackage ../all-pkgs/p/paste { };

path-py = callPackage ../all-pkgs/p/path-py { };
# Deprecated alias
pathpy = callPackageAlias "path-py" { };

pathlib = callPackage ../all-pkgs/p/pathlib { };

pathlib2 = callPackage ../all-pkgs/p/pathlib2 { };

pbr = callPackage ../all-pkgs/p/pbr { };

phonenumbers = callPackage ../all-pkgs/p/phonenumbers { };

pillow = callPackage ../all-pkgs/p/pillow { };

pip = callPackage ../all-pkgs/p/pip {
  buildPythonPackage = self.buildBootstrapPythonPackage;
};

ply = callPackage ../all-pkgs/p/ply { };

portend = callPackage ../all-pkgs/p/portend { };

prettytable = callPackage ../all-pkgs/p/prettytable { };

progressbar = callPackage ../all-pkgs/p/progressbar { };

psutil = callPackage ../all-pkgs/p/psutil { };

py = callPackage ../all-pkgs/p/py { };

py-bcrypt = callPackage ../all-pkgs/p/py-bcrypt { };

pyacoustid = callPackage ../all-pkgs/p/pyacoustid { };

pyasn1 = callPackage ../all-pkgs/p/pyasn1 { };

pyasn1-modules = callPackage ../all-pkgs/p/pyasn1-modules { };

pycairo = callPackage ../all-pkgs/p/pycairo { };

pycountry = callPackage ../all-pkgs/p/pycountry { };

pycparser = callPackage ../all-pkgs/p/pycparser { };

pycrypto = callPackage ../all-pkgs/p/pycrypto { };

pycryptodomex = callPackage ../all-pkgs/p/pycryptodomex { };

pycryptopp = callPackage ../all-pkgs/p/pycryptopp { };

pydenticon = callPackage ../all-pkgs/p/pydenticon { };

pygame = callPackage ../all-pkgs/p/pygame { };

pygments = callPackage ../all-pkgs/p/pygments { };

pygobject_2 = callPackage ../all-pkgs/p/pygobject {
  channel = "2.28";
};
pygobject_3-28 = callPackage ../all-pkgs/p/pygobject {
  channel = "3.28";
};
pygobject = callPackageAlias "pygobject_3-28" { };
pygobject_nocairo = callPackageAlias "pygobject_3-28" {
  cairo = null;
  pycairo = null;
};

pygtk = callPackage ../all-pkgs/p/pygtk { };

pykka = callPackage ../all-pkgs/p/pykka { };

pykwalify = callPackage ../all-pkgs/p/pykwalify { };

pylast = callPackage ../all-pkgs/p/pylast { };

pylint = callPackage ../all-pkgs/p/pylint { };

pymacaroons-pynacl = callPackage ../all-pkgs/p/pymacaroons-pynacl { };

pymysql = callPackage ../all-pkgs/p/pymysql { };

pynacl = callPackage ../all-pkgs/p/pynacl { };

pynzb = callPackage ../all-pkgs/p/pynzb { };

pyodbc = callPackage ../all-pkgs/p/pyodbc { };

pyopenssl = callPackage ../all-pkgs/p/pyopenssl { };

pyparsing = callPackage ../all-pkgs/p/pyparsing {
  buildPythonPackage = self.buildBootstrapPythonPackage;
};

pyrax = callPackage ../all-pkgs/p/pyrax { };

pyrss2gen = callPackage ../all-pkgs/p/pyrss2gen { };

pysaml2 = callPackage ../all-pkgs/p/pysaml2 { };

pyscard = callPackage ../all-pkgs/p/pyscard { };

pytest = callPackage ../all-pkgs/p/pytest { };

pytest-benchmark = callPackage ../all-pkgs/p/pytest-benchmark { };

pytest-capturelog = callPackage ../all-pkgs/p/pytest-capturelog { };

pytest-runner = callPackage ../all-pkgs/p/pytest-runner { };

python-dateutil = callPackage ../all-pkgs/p/python-dateutil { };

python-etcd = callpackage ../all-pkgs/p/python-etcd { };

python-ldap = callPackage ../all-pkgs/p/python-ldap { };

python-magic = callPackage ../all-pkgs/p/python-magic { };

python-mpd2 = callPackage ../all-pkgs/p/python-mpd2 { };

python-novaclient = callPackage ../all-pkgs/p/python-novaclient { };

python-tvrage = callPackage ../all-pkgs/p/python-tvrage { };

pytz = callPackage ../all-pkgs/p/pytz { };

pyudev = callPackage ../all-pkgs/p/pyudev { };

pyusb = callPackage ../all-pkgs/p/pyusb { };

pyutil = callPackage ../all-pkgs/p/pyutil { };

pywbem = callPackage ../all-pkgs/p/pywbem { };

pyxml = callPackage ../all-pkgs/p/pyxml { };

pyyaml = callPackage ../all-pkgs/p/pyyaml { };

pyzmq = callPackage ../all-pkgs/p/pyzmq { };

rackspace-auth-openstack =
  callPackage ../all-pkgs/r/rackspace-auth-openstack { };

rackspace-novaclient = callPackage ../all-pkgs/r/rackspace-novaclient { };

rarfile = callPackage ../all-pkgs/r/rarfile { };

rax-default-network-flags-python-novaclient-ext =
  callPackage ../all-pkgs/r/rax-default-network-flags-python-novaclient-ext { };

rax-scheduled-images-python-novaclient-ext =
  callPackage ../all-pkgs/r/rax-scheduled-images-python-novaclient-ext { };

rebulk = callPackage ../all-pkgs/r/rebulk { };

regex = callPackage ../all-pkgs/r/regex { };

repoze-who = callPackage ../all-pkgs/r/repoze-who { };

requests = callPackage ../all-pkgs/r/requests { };

requests-toolbelt = callPackage ../all-pkgs/r/requests-toolbelt { };

rpyc = callPackage ../all-pkgs/r/rpyc { };

rsa = callPackage ../all-pkgs/r/rsa { };

ruamel-yaml = callPackage ../all-pkgs/r/ruamel-yaml { };

s3transfer = callPackage ../all-pkgs/s/s3transfer { };

safe = callPackage ../all-pkgs/s/safe { };

salt_2016-11 = callPackage ../all-pkgs/s/salt {
  channel = "2016.11";
};
salt_2017-7 = callPackage ../all-pkgs/s/salt {
  channel = "2017.7";
};
salt_head = callPackage ../all-pkgs/s/salt {
  channel = "head";
};
salt = callPackageAlias "salt_2016-11" { };

scandir = callPackage ../all-pkgs/s/scandir { };

scons = callPackage ../all-pkgs/s/scons { };

secretstorage = callPackage ../all-pkgs/s/secretstorage { };

service-identity = callPackage ../all-pkgs/s/service-identity { };

setuptools = callPackage ../all-pkgs/s/setuptools {
  buildPythonPackage = self.buildBootstrapPythonPackage;
  inherit (self)
    appdirs
    packaging
    pyparsing
    six;
};

setuptools-scm = callPackage ../all-pkgs/s/setuptools-scm { };

setuptools-trial = callPackage ../all-pkgs/s/setuptools-trial { };

signedjson = callPackage ../all-pkgs/s/signedjson { };

simplejson = callPackage ../all-pkgs/s/simplejson { };

singledispatch = callPackage ../all-pkgs/s/singledispatch { };

six = callPackage ../all-pkgs/s/six {
  buildPythonPackage = self.buildBootstrapPythonPackage;
};

slimit = callPackage ../all-pkgs/s/slimit { };

snowballstemmer = callPackage ../all-pkgs/s/snowballstemmer { };

speedtest-cli = callPackage ../all-pkgs/s/speedtest-cli { };

sphinx = callPackage ../all-pkgs/s/sphinx { };

sphinxcontrib-websupport =
  callPackage ../all-pkgs/s/sphinxcontrib-websupport { };

sqlalchemy = callPackage ../all-pkgs/s/sqlalchemy { };

statistics = callPackage ../all-pkgs/s/statistics { };

stevedore = callPackage ../all-pkgs/s/stevedore { };

sydent = callPackage ../all-pkgs/s/sydent { };

synapse = callPackage ../all-pkgs/s/synapse { };

tahoe-lafs = callPackage ../all-pkgs/t/tahoe-lafs { };

tempora = callPackage ../all-pkgs/t/tempora { };

terminaltables = callPackage ../all-pkgs/t/terminaltables { };

tmdb3 = callPackage ../all-pkgs/t/tmdb3 { };

tornado = callPackage ../all-pkgs/t/tornado { };

transmission-remote-gnome =
  callPackage ../all-pkgs/t/transmission-remote-gnome { };

transmissionrpc = callPackage ../all-pkgs/t/transmissionrpc { };

twisted = callPackage ../all-pkgs/t/twisted { };

typing = callPackage ../all-pkgs/t/typing { };

tzlocal = callPackage ../all-pkgs/t/tzlocal { };

ujson = callPackage ../all-pkgs/u/ujson { };

unidecode = callPackage ../all-pkgs/u/unidecode { };

unpaddedbase64 = callPackage ../all-pkgs/u/unpaddedbase64 { };

urllib3 = callPackage ../all-pkgs/u/urllib3 { };

vapoursynth = callPackage ../all-pkgs/v/vapoursynth { };
vapoursynth_head = callPackage ../all-pkgs/v/vapoursynth {
  channel = "head";
};

vcversioner = callPackage ../all-pkgs/v/vcversioner { };

waf = callPackage ../all-pkgs/w/waf { };

webencodings = callPackage ../all-pkgs/w/webencodings { };

webob = callPackage ../all-pkgs/w/webob { };

werkzeug = callPackage ../all-pkgs/w/werkzeug { };

wheel = callPackage ../all-pkgs/w/wheel {
  buildPythonPackage = self.buildBootstrapPythonPackage;
};

wrapt = callPackage ../all-pkgs/w/wrapt { };

xcb-proto = callPackage ../all-pkgs/x/xcb-proto { };

youtube-dl = callPackage ../all-pkgs/y/youtube-dl { };

yubikey-manager = callPackage ../all-pkgs/y/yubikey-manager { };

zbase32 = callPackage ../all-pkgs/z/zbase32 { };

zfec = callPackage ../all-pkgs/z/zfec { };

zope-component = callPackage ../all-pkgs/z/zope-component { };

zope-event = callPackage ../all-pkgs/z/zope-event { };

zope-interface = callPackage ../all-pkgs/z/zope-interface { };

zxcvbn-python = callPackage ../all-pkgs/z/zxcvbn-python { };

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################ END ALL PKGS ##################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

   acme = buildPythonPackage rec {
     inherit (self.certbot) src version;
     name = "acme-${version}";
     srcRoot = "certbot-v${version}/acme";

     propagatedBuildInputs = with self; [
       cryptography
       mock
       ndg-httpsclient
       pyasn1
       pyopenssl
       pytz
       requests
       pyRFC3339
     ];

     disabled = isPy3;
   };

   audioread = buildPythonPackage rec {
     name = "audioread-${version}";
     version = "2.1.5";

     src = fetchPyPi {
       package = "audioread";
       inherit version;
       sha256 = "36c3b118f097c58ba073b7d040c4319eff200756f094295677567e256282d0d7";
     };

     # No tests, need to disable or py3k breaks

     meta = {
       description = "Cross-platform audio decoding";
       homepage = "https://github.com/sampsyo/audioread";
       license = licenses.mit;
     };
   };

   responses = self.buildPythonPackage rec {
     name = "responses-${version}";
     version = "0.9.0";

     src = fetchPyPi {
       package = "responses";
       inherit version;
       sha256 = "c6082710f4abfb60793899ca5f21e7ceb25aabf321560cc0726f8b59006811c9";
     };

     propagatedBuildInputs = with self; [
        cookies
        mock
        requests
        six
     ];
   };

   pyechonest = self.buildPythonPackage rec {
     name = "pyechonest-9.0.0";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/p/pyechonest/${name}.tar.gz";
       fullOpts = {
         md5Confirm = "c633dce658412e3ec553efd25d7d2686";
       };
       sha256 = "1584nira3rkiman9dm81kdshihmkj21s8navndz2l8spnjwb790x";
     };

     meta = {
       description = "Tap into The Echo Nest's Musical Brain for the best music search, information, recommendations and remix tools on the web";
       homepage = https://github.com/echonest/pyechonest;
     };
   };

   blinker = buildPythonPackage rec {
     name = "blinker-${version}";
     version = "1.4";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/b/blinker/${name}.tar.gz";
       fullOpts = {
         md5Confirm = "8b3722381f83c2813c52de3016b68d33";
       };
       sha256 = "1dpq0vb01p36jjwbhhd08ylvrnyvcc82yxx3mwjx6awrycjyw6j7";
     };

     meta = {
       homepage = http://pythonhosted.org/blinker/;
       description = "Fast, simple object-to-object and broadcast signaling";
       license = licenses.mit;
       maintainers = with maintainers; [ ];
     };
   };

   configobj = buildPythonPackage rec {
     name = "configobj-5.0.6";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/c/configobj/${name}.tar.gz";
       sha256 = "a2f5650770e1c87fb335af19a9b7eb73fc05ccf22144eb68db7d00cd2bcb0902";
     };

     buildInputs = with self; [
       six
     ];

     # error: invalid command 'test'
   };

   cookies = buildPythonPackage rec {
     name = "cookies-2.2.1";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/c/cookies/${name}.tar.gz";
       sha256 = "13pfndz8vbk4p2a44cfbjsypjarkrall71pgc97glk5fiiw9idnn";
     };


     meta = {
       description = "Friendlier RFC 6265-compliant cookie parser/renderer";
       homepage = https://github.com/sashahart/cookies;
       license = licenses.mit;
     };
   };

   coverage = buildPythonPackage rec {
     name = "coverage-${version}";
     version = "4.5.1";

     src = fetchPyPi {
       package = "coverage";
       inherit version;
       sha256 = "56e448f051a201c5ebbaa86a5efd0ca90d327204d8b059ab25ad0f35fbfd79f1";
     };
   };

   cov-core = buildPythonPackage rec {
     name = "cov-core-${version}";
     version = "1.15.0";

     src = fetchPyPi {
       package = "cov-core";
       inherit version;
       sha256 = "4a14c67d520fda9d42b0da6134638578caae1d374b9bb462d8de00587dba764c";
     };

     propagatedBuildInputs = with self; [
        coverage
     ];
    };

   pytestcov = buildPythonPackage (rec {
     name = "pytest-cov-${version}";
     version = "2.5.1";

     src = fetchPyPi {
       package = "pytest-cov";
       inherit version;
       sha256 = "03aa752cf11db41d281ea1d807d954c4eda35cfa1b21d6971966cc041bbf6e2d";
     };

    buildInputs = with self; [ cov-core pytest ];

     meta = {
       description = "plugin for coverage reporting with support for both centralised and distributed testing, including subprocesses and multiprocessing";
       homepage = https://github.com/schlamar/pytest-cov;
       license = licenses.mit;
     };
   });

   itsdangerous = buildPythonPackage rec {
     name = "itsdangerous-0.24";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/i/itsdangerous/${name}.tar.gz";
       sha256 = "06856q6x675ly542ig0plbqcyab6ksfzijlyf1hzhgg3sgwgrcyb";
     };
   };

   ndg-httpsclient = buildPythonPackage rec {
     name = "ndg-httpsclient-${version}";
     version = "0.4.2";

     src = fetchPyPi {
       package = "ndg_httpsclient";
       inherit version;
       sha256 = "580987ef194334c50389e0d7de885fccf15605c13c6eecaabd8d6c43768eb8ac";
     };

     buildInputs = with self; [
       pyopenssl
     ];
   };

   pyxdg = buildPythonPackage rec {
     name = "pyxdg-0.25";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/p/pyxdg/${name}.tar.gz";
       fullOpts = {
         md5Confirm = "bedcdb3a0ed85986d40044c87f23477c";
       };
       sha256 = "179767h8m634ydlm4v8lnz01ba42gckfp684id764zaip7h87s41";
     };

     # error: invalid command 'test'

     meta = {
       homepage = http://freedesktop.org/wiki/Software/pyxdg;
       description = "Contains implementations of freedesktop.org standards";
       license = licenses.lgpl2;
       maintainers = with maintainers; [ iElectric ];
     };
   };

   keepalive = buildPythonPackage rec {
     name = "keepalive-${version}";
     version = "0.5";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/k/keepalive/keepalive-${version}.tar.gz";
       sha256 = "3c6b96f9062a5a76022f0c9d41e9ef5552d80b1cadd4fccc1bf8f183ba1d1ec1";
     };

     # No tests included

     meta = with stdenv.lib; {
       description = "An HTTP handler for `urllib2` that supports HTTP 1.1 and keepalive.";
       homepage = "https://github.com/wikier/keepalive";
     };
   };


   SPARQLWrapper = buildPythonPackage rec {
     name = "SPARQLWrapper-${version}";
     version = "1.8.0";

     src = fetchPyPi {
       package = "SPARQLWrapper";
       inherit version;
       sha256 = "3b46d0f18ca0b65b8b965d6d1ae257b229388400b06e7dc19f0a51614dc1abde";
     };

     # break circular dependency loop
     patchPhase = ''
       sed -i '/rdflib/d' requirements.txt
     '';

     propagatedBuildInputs = with self; [
       six isodate pyparsing html5lib keepalive
     ];

     meta = with stdenv.lib; {
       description = "This is a wrapper around a SPARQL service. It helps in creating the query URI and, possibly, convert the result into a more manageable format.";
       homepage = "http://rdflib.github.io/sparqlwrapper";
     };
   };

   ecdsa = buildPythonPackage rec {
     name = "ecdsa-${version}";
     version = "0.13";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/e/ecdsa/${name}.tar.gz";
       sha256 = "1yj31j0asmrx4an9xvsaj2icdmzy6pw0glfpqrrkrphwdpi1xkv4";
     };

     # Only needed for tests
     buildInputs = with self; [ pkgs.openssl ];

     meta = {
       description = "ECDSA cryptographic signature library";
       homepage = "https://github.com/warner/python-ecdsa";
       license = licenses.mit;
       maintainers = with maintainers; [ aszlig ];
     };
   };

   feedparser = buildPythonPackage (rec {
     name = "feedparser-5.2.1";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/f/feedparser/${name}.tar.gz";
       sha256 = "1ycva69bqssalhqg45rbrfipz3l6hmycszy26k0351fhq990c0xx";
     };

     # lots of networking failures

     meta = {
       homepage = http://code.google.com/p/feedparser/;
       description = "Universal feed parser";
       license = licenses.bsd2;
       maintainers = with maintainers; [ iElectric ];
     };
   });

   flask-cors = buildPythonPackage rec {
     name = "Flask-Cors-${version}";
     version = "3.0.2";

     src = fetchPyPi {
       package = "Flask-Cors";
       inherit version;
       sha256 = "0a09f3559ded4759387dfa2a355de59bc161f67269a1f4b7b0712a64b1f7dad6";
     };
    buildInputs = with self; [ nose ];
     propagatedBuildInputs = with self; [ flask six ];

     meta = {
       description = "A Flask extension adding a decorator for CORS support";
       homepage = https://github.com/corydolphin/flask-cors;
      license = with licenses; [ mit ];
     };
   };

   python2-pythondialog = buildPythonPackage rec {
     name = "python2-pythondialog-${version}";
     version = "3.4.0";
     disabled = !isPy2;

     src = fetchPyPi {
       package = "python2-pythondialog";
       inherit version;
       sha256 = "a96d9cea9a371b5002b5575d1ec351233112519268d382ba6f3582323b3d1335";
     };

     patchPhase = ''
       substituteInPlace dialog.py ":/bin:/usr/bin" ":$out/bin"
     '';

     meta = with stdenv.lib; {
       homepage = "http://pythondialog.sourceforge.net/";
     };
   };

   pyRFC3339 = buildPythonPackage rec {
     name = "pyRFC3339-1.0";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/p/pyRFC3339/${name}.tar.gz";
       sha256 = "8dfbc6c458b8daba1c0f3620a8c78008b323a268b27b7359e92a4ae41325f535";
     };

     buildInputs = with self; [
       pytz
     ];

   };

   gyp = buildPythonPackage rec {
     name = "gyp-${version}";
     version = "2016-10-13";

     src = pkgs.fetchgit {
       version = 2;
       url = "https://chromium.googlesource.com/external/gyp.git";
       rev = "920ee58c3d3109dea3cd37d88054014891a93db7";
       sha256 = "0la5hvwjy1dap9f7vx48d2x59f5809vvp8500ig988p830b27fv1";
     };
   };

   jellyfish = buildPythonPackage rec {
     version = "0.5.6";
     name = "jellyfish-${version}";

     src = fetchPyPi {
       package = "jellyfish";
       inherit version;
       sha256 = "887a9a49d0caee913a883c3e7eb185f6260ebe2137562365be422d1316bd39c9";
     };

     buildInputs = with self; [
       pytest
       unicodecsv
     ];


     meta = {
       homepage = http://github.com/sunlightlabs/jellyfish;
       description = "Approximate and phonetic matching of strings";
       maintainers = with maintainers; [ ];
     };
   };

   mock = buildPythonPackage rec {
     name = "mock-2.0.0";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/m/mock/${name}.tar.gz";
       sha256 = "b158b6df76edd239b8208d481dc46b6afd45a846b7812ff0ce58971cf5bc8bba";
     };

     propagatedBuildInputs = with self; [
       funcsigs
       pbr
       six
     ];

   };

   munkres = buildPythonPackage rec {
     name = "munkres-${version}";
     version = "1.0.10";

     src = fetchPyPi {
       package = "munkres";
       inherit version;
       sha256 = "eb41e68e93be08ad8cb80fd470f8282f21cd2bac87b07da645e27cf9c6b014db";
     };

     # error: invalid command 'test'

     meta = {
       homepage = http://bmc.github.com/munkres/;
       description = "Munkres algorithm for the Assignment Problem";
       license = licenses.bsd3;
       maintainers = with maintainers; [ ];
     };
   };


   musicbrainzngs = buildPythonPackage rec {
     name = "musicbrainzngs-${version}";
     version = "0.6";

     src = fetchPyPi {
       package = "musicbrainzngs";
       inherit version;
       sha256 = "28ef261a421dffde0a25281dab1ab214e1b407eec568cd05a53e73256f56adb5";
     };

     buildInputs = [ pkgs.glibcLocales ];

     LC_ALL="en_US.UTF-8";

     meta = {
       homepage = http://alastair/python-musicbrainz-ngs;
       description = "Python bindings for musicbrainz NGS webservice";
       license = licenses.bsd2;
       maintainers = with maintainers; [ ];
     };
   };

   nose = buildPythonPackage rec {
     name = "nose-1.3.7";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/n/nose/${name}.tar.gz";
       sha256 = "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98";
     };
   };

   parsedatetime = buildPythonPackage rec {
     name = "parsedatetime-${version}";
     version = "2.4";

     src = fetchPyPi {
       package = "parsedatetime";
       inherit version;
       sha256 = "3d817c58fb9570d1eec1dd46fa9448cd644eeed4fb612684b02dfda3a79cb84b";
     };

     propagatedBuildInputs = [
      self.future
     ];
   };

   fixtures = buildPythonPackage rec {
     name = "fixtures-${version}";
     version = "3.0.0";

     src = fetchPyPi {
       package = "fixtures";
       inherit version;
       sha256 = "fcf0d60234f1544da717a9738325812de1f42c2fa085e2d9252d8fff5712b2ef";
     };

     buildInputs = with self; [ pbr testtools_1 mock ];

     meta = {
       description = "Reusable state for writing clean tests and more";
       homepage = "https://pypi.python.org/pypi/fixtures";
       license = licenses.asl20;
     };
   };

   plumbum = buildPythonPackage rec {
     name = "plumbum-${version}";
     version = "1.6.3";

     buildInputs = with self; [ self.six ];

     src = fetchPyPi {
       package = "plumbum";
       inherit version;
       sha256 = "0249e708459f1b05627a7ca8787622c234e4db495a532acbbd1f1f17f28c7320";
     };
   };

   pycurl = buildPythonPackage (rec {
     name = "pycurl-${version}";
     version = "7.43.0.1";
     disabled = isPyPy; # https://github.com/pycurl/pycurl/issues/208

     src = fetchPyPi {
       package = "pycurl";
       inherit version;
       sha256 = "43231bf2bafde923a6d9bb79e2407342a5f3382c1ef0a3b2e491c6a4e50b91aa";
     };

     propagatedBuildInputs = with self; [ pkgs.curl pkgs.openssl ];

     # error: invalid command 'test'

     preConfigure = ''
       substituteInPlace setup.py --replace '--static-libs' '--libs'
       export PYCURL_SSL_LIBRARY=openssl
     '';

     meta = {
       homepage = http://pycurl.io/;
       description = "Python wrapper for libcurl";
       platforms = platforms.linux;
     };
   });

   pyjwt = buildPythonPackage rec {
     version = "1.5.2";
     name = "pyjwt-${version}";

     src = fetchPyPi {
       package = "PyJWT";
       inherit version;
       sha256 = "1179f0bff86463b5308ee5f7aff1c350e1f38139d62a723e16fb2c557d1c795f";
     };

     propagatedBuildInputs = with self; [ pycrypto ecdsa pytest-runner ];


     meta = {
       description = "JSON Web Token implementation in Python";
       homepage = https://github.com/jpadilla/pyjwt;
       license = licenses.mit;
       maintainers = with maintainers; [ ];
       platforms = platforms.linux;
     };
   };

   pymongo = buildPythonPackage rec {
     name = "pymongo-${version}";
     version = "3.5.1";

     src = fetchPyPi {
       package = "pymongo";
       inherit version;
       sha256 = "e820d93414f3bec1fa456c84afbd4af1b43ff41366321619db74e6bc065d6924";
     };


     meta = {
       homepage = "http://github.com/mongodb/mongo-python-driver";
       license = licenses.asl20;
       description = "Python driver for MongoDB ";
     };
   };

   rdflib = buildPythonPackage (rec {
     name = "rdflib-${version}";
     version = "4.2.2";

     src = fetchPyPi {
       package = "rdflib";
       inherit version;
       sha256 = "da1df14552555c5c7715d8ce71c08f404c988c58a1ecd38552d0da4fc261280d";
     };

     # error: invalid command 'test'

     propagatedBuildInputs = with self; [ isodate html5lib SPARQLWrapper ];

     meta = {
       description = "A Python library for working with RDF, a simple yet powerful language for representing information";
       homepage = http://www.rdflib.net/;
     };
   });

   isodate = buildPythonPackage rec {
     name = "isodate-${version}";
     version = "0.5.4";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/i/isodate/${name}.tar.gz";
       sha256 = "42105c41d037246dc1987e36d96f3752ffd5c0c24834dd12e4fdbe1e79544e31";
     };

     meta = {
       description = "ISO 8601 date/time parser";
       homepage = http://cheeseshop.python.org/pypi/isodate;
     };
   };

   testscenarios = buildPythonPackage rec {
     name = "testscenarios-${version}";
     version = "0.5.0";

     src = fetchPyPi {
       package = "testscenarios";
       inherit version;
       sha256 = "c257cb6b90ea7e6f8fef3158121d430543412c9a87df30b5dde6ec8b9b57a2b6";
     };

     propagatedBuildInputs = with self; [ testtools ];

     meta = {
       description = "a pyunit extension for dependency injection";
       homepage = https://pypi.python.org/pypi/testscenarios;
       license = licenses.asl20;
     };
   };

  pyrsistent = buildPythonPackage rec {
    name = "pyrsistent-${version}";
    version = "0.12.3";

    src = fetchPyPi {
      package = "pyrsistent";
      inherit version;
      sha256 = "0614ad17af8a65d79b2550261c00686c241cea7278bf7a7fddfc7eed3f854068";
    };

    propagatedBuildInputs = with self; [
      six
    ];
  };

   testtools_1 = buildPythonPackage rec {
     name = "testtools-${version}";
     version = "1.9.0";

     src = fetchPyPi {
       package = "testtools";
       inherit version;
       sha256 = "b46eec2ad3da6e83d53f2b0eca9a8debb687b4f71343a074f83a16bbdb3c0644";
     };

     propagatedBuildInputs = with self; [
      extras
      pyrsistent
      pbr python_mimeparse extras lxml unittest2
    ];
     buildInputs = with self; [ traceback2 ];

     meta = {
       description = "A set of extensions to the Python standard library's unit testing framework";
       homepage = https://pypi.python.org/pypi/testtools;
       license = licenses.mit;
    };
   };

   testtools = buildPythonPackage rec {
     name = "testtools-${version}";
     version = "2.3.0";

     src = fetchPyPi {
       package = "testtools";
       inherit version;
       sha256 = "5827ec6cf8233e0f29f51025addd713ca010061204fdea77484a2934690a0559";
     };

     propagatedBuildInputs = with self; [
      extras
      fixtures
      pbr python_mimeparse extras lxml unittest2
    ];
     buildInputs = with self; [ traceback2 ];

     meta = {
       description = "A set of extensions to the Python standard library's unit testing framework";
       homepage = https://pypi.python.org/pypi/testtools;
       license = licenses.mit;
    };
   };

   python_mimeparse = buildPythonPackage rec {
     name = "python-mimeparse-${version}";
     version = "1.6.0";

     src = fetchPyPi {
       package = "python-mimeparse";
       inherit version;
       sha256 = "76e4b03d700a641fd7761d3cd4fdbbdcd787eade1ebfac43f877016328334f78";
     };

     # error: invalid command 'test'

     meta = {
       description = "A module provides basic functions for parsing mime-type names and matching them against a list of media-ranges";
       homepage = https://code.google.com/p/mimeparse/;
       license = licenses.mit;
     };
   };


   extras = buildPythonPackage rec {
     name = "extras-${version}";
     version = "1.0.0";

     src = fetchPyPi {
       package = "extras";
       inherit version;
       sha256 = "132e36de10b9c91d5d4cc620160a476e0468a88f16c9431817a6729611a81b4e";
     };

     # error: invalid command 'test'

     meta = {
       description = "A module provides basic functions for parsing mime-type names and matching them against a list of media-ranges";
       homepage = https://code.google.com/p/mimeparse/;
       license = licenses.mit;
     };
   };

   unicodecsv = buildPythonPackage rec {
     version = "0.14.1";
     name = "unicodecsv-${version}";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/u/unicodecsv/${name}.tar.gz";
       sha256 = "1z7pdwkr6lpsa7xbyvaly7pq3akflbnz8gq62829lr28gl1hi301";
     };

     # ImportError: No module named runtests

     meta = {
       description = "Drop-in replacement for Python2's stdlib csv module, with unicode support";
       homepage = https://github.com/jdunck/python-unicodecsv;
       maintainers = with maintainers; [ koral ];
     };
   };

   # DEPRECATED: required by testtools, remove this package if the dependency is dropped
   unittest2 = buildPythonPackage rec {
     version = "1.1.0";
     name = "unittest2-${version}";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/u/unittest2/unittest2-${version}.tar.gz";
       sha256 = "0y855kmx7a8rnf81d3lh5lyxai1908xjp0laf4glwa4c8472m212";
     };

     # # 1.0.0 and up create a circle dependency with traceback2/pbr

     postPatch = ''
       # # fixes a transient error when collecting tests, see https://bugs.launchpad.net/python-neutronclient/+bug/1508547
       sed -i '510i\        return None, False' unittest2/loader.py
       # https://github.com/pypa/packaging/pull/36
       sed -i 's/version=VERSION/version=str(VERSION)/' setup.py
     '' + /* argparse is part of the standard library */ ''
       sed -i setup.py \
        -e "s/'argparse',//"
     '';

     propagatedBuildInputs = with self; [ six traceback2 ];

     meta = {
       description = "A backport of the new features added to the unittest testing framework";
       homepage = https://pypi.python.org/pypi/unittest2;
     };
   };

   traceback2 = buildPythonPackage rec {
     version = "1.4.0";
     name = "traceback2-${version}";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/t/traceback2/traceback2-${version}.tar.gz";
       sha256 = "0c1h3jas1jp1fdbn9z2mrgn3jj0hw1x3yhnkxp7jw34q15xcdb05";
     };

     propagatedBuildInputs = with self; [ pbr linecache2 ];
     # circular dependencies for tests

     meta = {
       description = "A backport of traceback to older supported Pythons.";
       homepage = https://pypi.python.org/pypi/traceback2/;
     };
   };

   linecache2 = buildPythonPackage rec {
     name = "linecache2-${version}";
     version = "1.0.0";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/l/linecache2/${name}.tar.gz";
       sha256 = "0z79g3ds5wk2lvnqw0y2jpakjf32h95bd9zmnvp7dnqhf57gy9jb";
     };

     buildInputs = with self; [ pbr ];
     # circular dependencies for tests

     meta = with stdenv.lib; {
       description = "A backport of linecachetestscenarios to older supported Pythons.";
       homepage = "https://github.com/testing-cabal/linecache2";
     };
   };

}
