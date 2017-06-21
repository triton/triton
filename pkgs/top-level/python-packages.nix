{ pkgs, stdenv, python, self }:

with pkgs.lib;

let
  pythonAtLeast = versionAtLeast python.channel;
  pythonOlder = versionOlder python.channel;
  isPy27 = python.channel == "2.7";
  isPy33 = python.channel == "3.3";
  isPy34 = python.channel == "3.4";
  isPy35 = python.channel == "3.5";
  isPy36 = python.channel == "3.6";
  isPyPy = python.executable == "pypy";
  isPy3k = strings.substring 0 1 python.channel == "3";

  fetchPyPi = { package, version, sha256, type ? ".tar.gz" }:
    pkgs.fetchurl rec {
      name = "${package}-${version}${type}";
      url = "https://localhost/not-a-url";
      preFetch = ''
        $curl 'https://pypi.python.org/pypi/${package}/json' | \
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
      inherit sha256;
    };

  buildPythonPackage = makeOverridable (
    callPackage ../all-pkgs/b/build-python-package {
      pip_bootstrap = callPackage ../all-pkgs/p/pip/bootstrap.nix {
        inherit (self) wrapPython;
      };
    }
  );

  # Unique python version identifier
  pythonName =
    if isPy27 then
      "python27"
    else if isPy33 then
      "python33"
    else if isPy34 then
      "python34"
    else if isPy35 then
      "python35"
    else if isPy36 then
      "python36"
    else if isPyPy then
      "pypy"
    else
      "";

  callPackage = pkgs.newScope (self // {
    inherit pkgs;
    pythonPackages = self;
  });

  callPackageAlias = package: newAttrs: self."${package}".override newAttrs;

in {

  inherit
    buildPythonPackage
    fetchPyPi
    isPy27
    isPy33
    isPy34
    isPy35
    isPy36
    isPyPy
    isPy3k
    python
    pythonAtLeast
    pythonName
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
        quoteVariants = [ "'\"'''\"'" "\"\"\"" "\"" "'\"'\"'" ];

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

alabaster = callPackage ../all-pkgs/a/alabaster { };

aniso8601 = callPackage ../all-pkgs/a/aniso8601 { };

ansible = callPackage ../all-pkgs/a/ansible { };

apache-libcloud = callPackage ../all-pkgs/a/apache-libcloud { };

appdirs = callPackage ../all-pkgs/a/appdirs { };

apscheduler = callPackage ../all-pkgs/a/apscheduler { };

asciinema = callPackage ../all-pkgs/a/asciinema { };

asn1crypto = callPackage ../all-pkgs/a/asn1crypto { };

attrs = callPackage ../all-pkgs/a/attrs { };

automat = callPackage ../all-pkgs/a/automat { };

aws-cli = callPackage ../all-pkgs/a/aws-cli { };

babel = callPackage ../all-pkgs/b/babel { };

babelfish = callPackage ../all-pkgs/b/babelfish { };

backports-abc = callPackage ../all-pkgs/b/backports-abc { };

backports-ssl-match-hostname =
  callPackage ../all-pkgs/b/backports-ssl-match-hostname { };

bazaar = callPackage ../all-pkgs/b/bazaar { };

bcrypt = callPackage ../all-pkgs/b/bcrypt { };

beautifulsoup = callPackage ../all-pkgs/b/beautifulsoup { };

beets = callPackage ../all-pkgs/b/beets { };

bleach = callPackage ../all-pkgs/b/bleach { };

blist = callPackage ../all-pkgs/b/blist { };

borgbackup = callPackage ../all-pkgs/b/borgbackup { };

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

cheroot = callPackage ../all-pkgs/c/cheroot { };

cherrypy = callPackage ../all-pkgs/c/cherrypy { };

click = callPackage ../all-pkgs/c/click { };

colorama = callPackage ../all-pkgs/c/colorama { };

colorclass = callPackage ../all-pkgs/c/colorclass { };

constantly = callPackage ../all-pkgs/c/constantly { };

cryptography = callPackage ../all-pkgs/c/cryptography { };

cryptography-vectors = callPackage ../all-pkgs/c/cryptography-vectors { };

cvs2svn = callPackage ../all-pkgs/c/cvs2svn { };

cython = callPackage ../all-pkgs/c/cython { };

daemonize = callPackage ../all-pkgs/d/daemonize { };

decorator = callPackage ../all-pkgs/d/decorator { };

deluge = callPackage ../all-pkgs/d/deluge { };

diffoscope = callPackage ../all-pkgs/d/diffoscope { };

discogs-client = callPackage ../all-pkgs/d/discogs-client { };

dnsdiag = callPackage ../all-pkgs/d/dnsdiag { };

dnspython = callPackage ../all-pkgs/d/dnspython { };

docutils = callPackage ../all-pkgs/d/docutils { };

duplicity = callPackage ../all-pkgs/d/duplicity { };

enum34 = callPackage ../all-pkgs/e/enum34 { };

etcd = callPackage ../all-pkgs/e/etcd { };

fasteners = callPackage ../all-pkgs/f/fasteners { };

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

gst-python_1-10 = callPackage ../all-pkgs/g/gst-python {
  channel = "1.10";
  gst-plugins-base = pkgs.gst-plugins-base_1-10;
  gstreamer = pkgs.gstreamer_1-10;
};
gst-python_1-12 = callPackage ../all-pkgs/g/gst-python {
  channel = "1.12";
  gst-plugins-base = pkgs.gst-plugins-base_1-12;
  gstreamer = pkgs.gstreamer_1-12;
};
gst-python = callPackageAlias "gst-python_1-10" { };

guessit = callPackage ../all-pkgs/g/guessit { };

html5lib = callPackage ../all-pkgs/h/html5lib { };

hyperlink = callPackage ../all-pkgs/h/hyperlink { };

idna = callPackage ../all-pkgs/i/idna { };

incremental = callPackage ../all-pkgs/i/incremental { };

iotop = callPackage ../all-pkgs/i/iotop { };

imagesize = callPackage ../all-pkgs/i/imagesize { };

ipaddress = callPackage ../all-pkgs/i/ipaddress { };

jinja2 = callPackage ../all-pkgs/j/jinja2 { };

jmespath = callPackage ../all-pkgs/j/jmespath { };

jsonschema = callPackage ../all-pkgs/j/jsonschema { };

ldap3 = callPackage ../all-pkgs/l/ldap3 { };

libarchive-c = callPackage ../all-pkgs/l/libarchive-c { };

lxml = callPackage ../all-pkgs/l/lxml { };

m2crypto = callPackage ../all-pkgs/m/m2crypto { };

m2r = callPackage ../all-pkgs/m/m2r { };

markupsafe = callPackage ../all-pkgs/m/markupsafe { };

matrix-angular-sdk = callPackage ../all-pkgs/m/matrix-angular-sdk { };

matrix-synapse-ldap3 = callPackage ../all-pkgs/m/matrix-synapse-ldap3 { };

mistune = callPackage ../all-pkgs/m/mistune { };

monotonic = callPackage ../all-pkgs/m/monotonic { };

mopidy = callPackage ../all-pkgs/m/mopidy { };

msgpack-python = callPackage ../all-pkgs/m/msgpack-python { };

mutagen = callPackage ../all-pkgs/m/mutagen { };

netaddr = callPackage ../all-pkgs/n/netaddr { };

nevow = callPackage ../all-pkgs/n/nevow { };

notify-python = callPackage ../all-pkgs/n/notify-python { };

oauthlib = callPackage ../all-pkgs/o/oauthlib { };

olefile = callPackage ../all-pkgs/o/olefile { };

packaging = callPackage ../all-pkgs/p/packaging { };

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

pip = callPackage ../all-pkgs/p/pip { };

ply = callPackage ../all-pkgs/p/ply { };

progressbar = callPackage ../all-pkgs/p/progressbar { };

psutil = callPackage ../all-pkgs/p/psutil { };

py = callPackage ../all-pkgs/p/py { };

py-bcrypt = callPackage ../all-pkgs/p/py-bcrypt { };

pyacoustid = callPackage ../all-pkgs/p/pyacoustid { };

pyasn1 = callPackage ../all-pkgs/p/pyasn1 { };

pyasn1-modules = callPackage ../all-pkgs/p/pyasn1-modules { };

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
pygobject_3-24 = callPackage ../all-pkgs/p/pygobject {
  channel = "3.24";
};
pygobject = callPackageAlias "pygobject_3-24" { };

pygtk = callPackage ../all-pkgs/p/pygtk { };

pykka = callPackage ../all-pkgs/p/pykka { };

pylast = callPackage ../all-pkgs/p/pylast { };

pymacaroons-pynacl = callPackage ../all-pkgs/p/pymacaroons-pynacl { };

pymysql = callPackage ../all-pkgs/p/pymysql { };

pynacl = callPackage ../all-pkgs/p/pynacl { };

pynzb = callPackage ../all-pkgs/p/pynzb { };

pyodbc = callPackage ../all-pkgs/p/pyodbc { };

pyopenssl = callPackage ../all-pkgs/p/pyopenssl { };

pyparsing = callPackage ../all-pkgs/p/pyparsing { };

pyrss2gen = callPackage ../all-pkgs/p/pyrss2gen { };

pysaml2 = callPackage ../all-pkgs/p/pysaml2 { };

pytest = callPackage ../all-pkgs/p/pytest { };

pytest-benchmark = callPackage ../all-pkgs/p/pytest-benchmark { };

pytest-capturelog = callPackage ../all-pkgs/p/pytest-capturelog { };

pytest-runner = callPackage ../all-pkgs/p/pytest-runner { };

python-dateutil = callPackage ../all-pkgs/p/python-dateutil { };

python-etcd = callpackage ../all-pkgs/p/python-etcd { };

python-ldap = callPackage ../all-pkgs/p/python-ldap { };

python-magic = callPackage ../all-pkgs/p/python-magic { };

python-tvrage = callPackage ../all-pkgs/p/python-tvrage { };

pytz = callPackage ../all-pkgs/p/pytz { };

pywbem = callPackage ../all-pkgs/p/pywbem { };

pyudev = callPackage ../all-pkgs/p/pyudev { };

pyutil = callPackage ../all-pkgs/p/pyutil { };

pyyaml = callPackage ../all-pkgs/p/pyyaml { };

pyzmq = callPackage ../all-pkgs/p/pyzmq { };

rarfile = callPackage ../all-pkgs/r/rarfile { };

rebulk = callPackage ../all-pkgs/r/rebulk { };

regex = callPackage ../all-pkgs/r/regex { };

repoze-who = callPackage ../all-pkgs/r/repoze-who { };

requests = callPackage ../all-pkgs/r/requests { };

requests-toolbelt = callPackage ../all-pkgs/r/requests-toolbelt { };

rpyc = callPackage ../all-pkgs/r/rpyc { };

rsa = callPackage ../all-pkgs/r/rsa { };

s3transfer = callPackage ../all-pkgs/s/s3transfer { };

safe = callPackage ../all-pkgs/s/safe { };

salt_2016-3 = callPackage ../all-pkgs/s/salt {
  channel = "2016.3";
};
salt_2016-11 = callPackage ../all-pkgs/s/salt {
  channel = "2016.11";
};
salt_head = callPackage ../all-pkgs/s/salt {
  channel = "head";
};
salt = callPackageAlias "salt_2016-11" { };

scandir = callPackage ../all-pkgs/s/scandir { };

scons = callPackage ../all-pkgs/s/scons { };

service-identity = callPackage ../all-pkgs/s/service-identity { };

setuptools = callPackage ../all-pkgs/s/setuptools { };

setuptools-scm = callPackage ../all-pkgs/s/setuptools-scm { };

setuptools-trial = callPackage ../all-pkgs/s/setuptools-trial { };

signedjson = callPackage ../all-pkgs/s/signedjson { };

simplejson = callPackage ../all-pkgs/s/simplejson { };

singledispatch = callPackage ../all-pkgs/s/singledispatch { };

six = callPackage ../all-pkgs/s/six { };

slimit = callPackage ../all-pkgs/s/slimit { };

snowballstemmer = callPackage ../all-pkgs/s/snowballstemmer { };

speedtest-cli = callPackage ../all-pkgs/s/speedtest-cli { };

sphinx = callPackage ../all-pkgs/s/sphinx { };

sqlalchemy = callPackage ../all-pkgs/s/sqlalchemy { };

statistics = callPackage ../all-pkgs/s/statistics { };

sydent = callPackage ../all-pkgs/s/sydent { };

synapse = callPackage ../all-pkgs/s/synapse { };

tahoe-lafs = callPackage ../all-pkgs/t/tahoe-lafs { };

tempora = callPackage ../all-pkgs/t/tempora { };

terminaltables = callPackage ../all-pkgs/t/terminaltables { };

tmdb3 = callPackage ../all-pkgs/t/tmdb3 { };

tornado = callPackage ../all-pkgs/t/tornado { };

transmissionrpc = callPackage ../all-pkgs/t/transmissionrpc { };

twisted = callPackage ../all-pkgs/t/twisted { };

typing = callPackage ../all-pkgs/t/typing { };

tzlocal = callPackage ../all-pkgs/t/tzlocal { };

ujson = callPackage ../all-pkgs/u/ujson { };

unidecode = callPackage ../all-pkgs/u/unidecode { };

unpaddedbase64 = callPackage ../all-pkgs/u/unpaddedbase64 { };

urllib3 = callPackage ../all-pkgs/u/urllib3 { };

vcversioner = callPackage ../all-pkgs/v/vcversioner { };

webencodings = callPackage ../all-pkgs/w/webencodings { };

webob = callPackage ../all-pkgs/w/webob { };

werkzeug = callPackage ../all-pkgs/w/werkzeug { };

wheel = callPackage ../all-pkgs/w/wheel { };

xcb-proto = callPackage ../all-pkgs/x/xcb-proto { };

youtube-dl = callPackage ../all-pkgs/y/youtube-dl { };

zbase32 = callPackage ../all-pkgs/z/zbase32 { };

zfec = callPackage ../all-pkgs/z/zfec { };

zope-component = callPackage ../all-pkgs/z/zope-component { };

zope-event = callPackage ../all-pkgs/z/zope-event { };

zope-interface = callPackage ../all-pkgs/z/zope-interface { };

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

   pycairo = callPackage ../all-pkgs/p/pycairo { };

   acme = buildPythonPackage rec {
     inherit (self.certbot) src version;
     name = "acme-${version}";
     sourceRoot = "certbot-v${version}/acme";

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

     disabled = isPy3k;
   };

   argparse = buildPythonPackage rec {
     name = "argparse-1.4.0";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/a/argparse/${name}.tar.gz";
       sha256 = "1r6nznp64j68ih1k537wms7h57nvppq0szmwsaf99n71bfjqkc32";
     };
   };

   audioread = buildPythonPackage rec {
     name = "audioread-${version}";
     version = "2.1.4";

     src = fetchPyPi {
       package = "audioread";
       inherit version;
       sha256 = "8ffee2d2787258c214841853f600c52943baea9ad2303cb3d4b625cde4f08fff";
     };

     # No tests, need to disable or py3k breaks

     meta = {
       description = "Cross-platform audio decoding";
       homepage = "https://github.com/sampsyo/audioread";
       license = licenses.mit;
     };
   };

   responses = self.buildPythonPackage rec {
     name = "responses-0.5.1";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/r/responses/${name}.tar.gz";
       md5Confirm = "f1962b295b18128c522e83901556deac";
       sha256 = "1spcfxixyk9k7pk82jm6zqkwk031s95lh8q0mz7539jrb7269bcc";
     };

     propagatedBuildInputs = with self; [ cookies mock requests six ];


   };

   pyechonest = self.buildPythonPackage rec {
     name = "pyechonest-9.0.0";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/p/pyechonest/${name}.tar.gz";
       md5Confirm = "c633dce658412e3ec553efd25d7d2686";
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
       md5Confirm = "8b3722381f83c2813c52de3016b68d33";
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
     version = "4.2";

     src = fetchPyPi {
       package = "coverage";
       inherit version;
       sha256 = "e312776d3ef04632ec742ce2d2b7048b635073e0245e4f44dfe8b08cc50ac656";
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
     version = "2.3.1";

     src = fetchPyPi {
       package = "pytest-cov";
       inherit version;
       sha256 = "fa0a212283cdf52e2eecc24dd6459bb7687cc29adb60cb84258fab73be8dda0f";
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
       md5Confirm = "bedcdb3a0ed85986d40044c87f23477c";
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
     version = "1.7.6";

     src = fetchPyPi {
       package = "SPARQLWrapper";
       inherit version;
       sha256 = "dccabec900eb9c97cb47834bd4b66ceaeb4d9ea11bae24a24fe734e9f48522f8";
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
     disabled = !isPy27;

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

   lockfile = buildPythonPackage rec {
     name = "lockfile-0.12.2";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/l/lockfile/${name}.tar.gz";
       sha256 = "16gpx5hm73ah5n1079ng0vy381hl802v606npkx4x8nb0gg05vba";
     };

     buildInputs = with self; [
       pbr
     ];


     meta = {
       homepage = http://launchpad.net/pylockfile;
       description = "Platform-independent advisory file locking capability for Python applications";
       license = licenses.asl20;
     };
   };

   Mako = buildPythonPackage rec {
     name = "Mako-${version}";
     version = "1.0.6";

     src = fetchPyPi {
        package = "Mako";
        inherit version;
       sha256 = "48559ebd872a8e77f92005884b3d88ffae552812cdf17db6768e5c3be5ebbe0d";
     };

     buildInputs = with self; [
       markupsafe
     ];

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

   mpd = buildPythonPackage rec {
     name = "python-mpd-0.3.0";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/p/python-mpd/python-mpd-0.3.0.tar.gz";
       md5Confirm = "5b3849b131e2fb12f251434597d65635";
       sha256 = "1d11rl46prk5n8chmaxwwhi3c85s4gxadxapfkilc3rf3nx2x082";
     };

     meta = with pkgs.stdenv.lib; {
       description = "An MPD (Music Player Daemon) client library written in pure Python";
       homepage = http://jatreuman.indefero.net/p/python-mpd/;
      license = licenses.gpl3;
     };
   };

   munkres = buildPythonPackage rec {
     name = "munkres-${version}";
     version = "1.0.8";

     src = fetchPyPi {
       package = "munkres";
       inherit version;
       sha256 = "185f1a9c4d2c31f2f19afa48bc2ec726c11e945eded4784d272da2fd49bf7a55";
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
     name = "parsedatetime-2.1";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/p/parsedatetime/${name}.tar.gz";
       sha256 = "17c578775520c99131634e09cfca5a05ea9e1bd2a05cd06967ebece10df7af2d";
     };

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
     version = "1.6.2";

     buildInputs = with self; [ self.six ];

     src = fetchPyPi {
       package = "plumbum";
       inherit version;
       sha256 = "75eff3a55e056d8fc06f7b7ceb603ce4c26650cd6a2196bcdb0b80fee59471a8";
     };
   };

   pycurl = buildPythonPackage (rec {
     name = "pycurl-${version}";
     version = "7.43.0";
     disabled = isPyPy; # https://github.com/pycurl/pycurl/issues/208

     src = fetchPyPi {
       package = "pycurl";
       inherit version;
       sha256 = "aa975c19b79b6aa6c0518c0cc2ae33528900478f0b500531dbcdbf05beec584c";
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
     version = "1.4.2";
     name = "pyjwt-${version}";

     src = fetchPyPi {
       package = "PyJWT";
       inherit version;
       sha256 = "87a831b7a3bfa8351511961469ed0462a769724d4da48a501cb8c96d1e17f570";
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
     version = "3.3.0";

     src = fetchPyPi {
       package = "pymongo";
       inherit version;
       sha256 = "3d45302fc2622fabf34356ba274c69df41285bac71bbd229f1587283b851b91e";
     };


     meta = {
       homepage = "http://github.com/mongodb/mongo-python-driver";
       license = licenses.asl20;
       description = "Python driver for MongoDB ";
     };
   };

   rdflib = buildPythonPackage (rec {
     name = "rdflib-4.2.1";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/r/rdflib/${name}.tar.gz";
       sha256 = "eb02bd235606ef3b26e213da3e576557a6392ce103efd8c6c8ff1e08321608c8";
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
    version = "0.11.13";

    src = fetchPyPi {
      package = "pyrsistent";
      inherit version;
      sha256 = "cfbf194cb33b97722f6a3d6efa7b6e7a93b09bb13571266cfc9c1556fdb26f29";
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
     version = "2.2.0";

     src = fetchPyPi {
       package = "testtools";
       inherit version;
       sha256 = "80f606607a6e4ce4d0e24e5b786562aa42c581906f3c070607a4265f3da65810";
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

   unittest2 = buildPythonPackage rec {
     version = "1.1.0";
     name = "unittest2-${version}";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/u/unittest2/unittest2-${version}.tar.gz";
       sha256 = "0y855kmx7a8rnf81d3lh5lyxai1908xjp0laf4glwa4c8472m212";
     };

     # # 1.0.0 and up create a circle dependency with traceback2/pbr

     patchPhase = ''
       # # fixes a transient error when collecting tests, see https://bugs.launchpad.net/python-neutronclient/+bug/1508547
       sed -i '510i\        return None, False' unittest2/loader.py
       # https://github.com/pypa/packaging/pull/36
       sed -i 's/version=VERSION/version=str(VERSION)/' setup.py
     '';

     propagatedBuildInputs = with self; [ six argparse traceback2 ];

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
