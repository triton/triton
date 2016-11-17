{ pkgs, stdenv, python, self }:

with pkgs.lib;

let
  pythonAtLeast = versionAtLeast python.channel;
  pythonOlder = versionOlder python.channel;
  isPy27 = python.channel == "2.7";
  isPy33 = python.channel == "3.3";
  isPy34 = python.channel == "3.4";
  isPy35 = python.channel == "3.5";
  isPyPy = python.executable == "pypy";
  isPy3k = strings.substring 0 1 python.channel == "3";

  fetchPyPi = { package, version, sha256, type ? ".tar.gz" }:
    pkgs.fetchurl rec {
      name = "${package}-${version}${type}";
      url = "http://localhost/not-a-url";
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

alabaster = callPackage ../all-pkgs/a/alabaster { };

aniso8601 = callPackage ../all-pkgs/a/aniso8601 { };

apscheduler = callPackage ../all-pkgs/a/apscheduler { };

asciinema = callPackage ../all-pkgs/a/asciinema { };

attrs = callPackage ../all-pkgs/a/attrs { };

aws-cli = callPackage ../all-pkgs/a/aws-cli { };

babel = callPackage ../all-pkgs/b/babel { };

babelfish = callPackage ../all-pkgs/b/babelfish { };

backports-abc = callPackage ../all-pkgs/b/backports-abc { };

backports-ssl-match-hostname =
  callPackage ../all-pkgs/b/backports-ssl-match-hostname { };

bazaar = callPackage ../all-pkgs/b/bazaar { };

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

cffi = callPackage ../all-pkgs/c/cffi { };

chardet = callPackage ../all-pkgs/c/chardet { };

cherrypy = callPackage ../all-pkgs/c/cherrypy { };

click = callPackage ../all-pkgs/c/click { };

colorama = callPackage ../all-pkgs/c/colorama { };

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

docutils = callPackage ../all-pkgs/d/docutils { };

duplicity = callPackage ../all-pkgs/d/duplicity { };

enum34 = callPackage ../all-pkgs/e/enum34 { };

flask = callPackage ../all-pkgs/f/flask { };

flask-compress = callPackage ../all-pkgs/f/flask-compress { };

flask-login = callPackage ../all-pkgs/f/flask-login { };

flask-restful = callPackage ../all-pkgs/f/flask-restful { };

flask-restplus = callPackage ../all-pkgs/f/flask-restplus { };

flexget = callPackage ../all-pkgs/f/flexget { };

fonttools = callPackage ../all-pkgs/f/fonttools { };

frozendict = callPackage ../all-pkgs/f/frozendict { };

funcsigs = callPackage ../all-pkgs/f/funcsigs { };

future = callPackage ../all-pkgs/f/future { };

futures = callPackage ../all-pkgs/f/futures { };

gst-python_1-8 = callPackage ../all-pkgs/g/gst-python {
  channel = "1.8";
  gst-plugins-base = pkgs.gst-plugins-base_1-8;
  gstreamer = pkgs.gstreamer_1-8;
};
gst-python_1-10 = callPackage ../all-pkgs/g/gst-python {
  channel = "1.10";
  gst-plugins-base = pkgs.gst-plugins-base_1-10;
  gstreamer = pkgs.gstreamer_1-10;
};
gst-python = callPackageAlias "gst-python_1-10" { };

guessit = callPackage ../all-pkgs/g/guessit { };

html5lib = callPackage ../all-pkgs/h/html5lib { };

idna = callPackage ../all-pkgs/i/idna { };

incremental = callPackage ../all-pkgs/i/incremental { };

iotop = callPackage ../all-pkgs/i/iotop { };

imagesize = callPackage ../all-pkgs/i/imagesize { };

ipaddress = callPackage ../all-pkgs/i/ipaddress { };

jinja2 = callPackage ../all-pkgs/j/jinja2 { };

jmespath = callPackage ../all-pkgs/j/jmespath { };

ldap3 = callPackage ../all-pkgs/l/ldap3 { };

libarchive-c = callPackage ../all-pkgs/l/libarchive-c { };

markupsafe = callPackage ../all-pkgs/m/markupsafe { };

matrix-angular-sdk = callPackage ../all-pkgs/m/matrix-angular-sdk { };

mopidy = callPackage ../all-pkgs/m/mopidy { };

msgpack-python = callPackage ../all-pkgs/m/msgpack-python { };

mutagen = callPackage ../all-pkgs/m/mutagen { };

netaddr = callPackage ../all-pkgs/n/netaddr { };

notify-python = callPackage ../all-pkgs/n/notify-python { };

paste = callPackage ../all-pkgs/p/paste { };

pathlib = callPackage ../all-pkgs/p/pathlib { };

pathlib2 = callPackage ../all-pkgs/p/pathlib2 { };

pbr = callPackage ../all-pkgs/p/pbr { };

pillow = callPackage ../all-pkgs/p/pillow { };

pip = callPackage ../all-pkgs/p/pip { };

ply = callPackage ../all-pkgs/p/ply { };

progressbar = callPackage ../all-pkgs/p/progressbar { };

psutil = callPackage ../all-pkgs/p/psutil { };

py = callPackage ../all-pkgs/p/py { };

py-bcrypt = callPackage ../all-pkgs/p/py-bcrypt { };

pyasn1 = callPackage ../all-pkgs/p/pyasn1 { };

pyasn1-modules = callPackage ../all-pkgs/p/pyasn1-modules { };

pycountry = callPackage ../all-pkgs/p/pycountry { };

pycparser = callPackage ../all-pkgs/p/pycparser { };

pycryptodomex = callPackage ../all-pkgs/p/pycryptodomex { };

pydenticon = callPackage ../all-pkgs/p/pydenticon { };

pygame = callPackage ../all-pkgs/p/pygame { };

pygments = callPackage ../all-pkgs/p/pygments { };

pygtk = callPackage ../all-pkgs/p/pygtk { };

pykka = callPackage ../all-pkgs/p/pykka { };

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

python-dateutil = callPackage ../all-pkgs/p/python-dateutil { };

python-ldap = callPackage ../all-pkgs/p/python-ldap { };

python-magic = callPackage ../all-pkgs/p/python-magic { };

python-tvrage = callPackage ../all-pkgs/p/python-tvrage { };

pytz = callPackage ../all-pkgs/p/pytz { };

pyyaml = callPackage ../all-pkgs/p/pyyaml { };

rebulk = callPackage ../all-pkgs/r/rebulk { };

regex = callPackage ../all-pkgs/r/regex { };

repoze-who = callPackage ../all-pkgs/r/repoze-who { };

requests = callPackage ../all-pkgs/r/requests { };

rpyc = callPackage ../all-pkgs/r/rpyc { };

rsa = callPackage ../all-pkgs/r/rsa { };

s3transfer = callPackage ../all-pkgs/s/s3transfer { };

safe = callPackage ../all-pkgs/s/safe { };

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

tmdb3 = callPackage ../all-pkgs/t/tmdb3 { };

tornado = callPackage ../all-pkgs/t/tornado { };

transmissionrpc = callPackage ../all-pkgs/t/transmissionrpc { };

twisted = callPackage ../all-pkgs/t/twisted { };

tzlocal = callPackage ../all-pkgs/t/tzlocal { };

ujson = callPackage ../all-pkgs/u/ujson { };

unpaddedbase64 = callPackage ../all-pkgs/u/unpaddedbase64 { };

webencodings = callPackage ../all-pkgs/w/webencodings { };

webob = callPackage ../all-pkgs/w/webob { };

werkzeug = callPackage ../all-pkgs/w/werkzeug { };

wheel = callPackage ../all-pkgs/w/wheel { };

xcb-proto = callPackage ../all-pkgs/x/xcb-proto { };

youtube-dl = callPackage ../all-pkgs/y/youtube-dl { };

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

  pycrypto = callPackage ../development/python-modules/pycrypto { };

   pygobject_2 = callPackage ../development/python-modules/pygobject { };
   # Deprecated Alias
   pygobject = callPackageAlias "pygobject_2" { };
   pygobject_3 = callPackage ../development/python-modules/pygobject/3.nix { };
   # Deprecated Alias
   pygobject3 = callPackageAlias "pygobject_3" { };

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

   rarfile = self.buildPythonPackage rec {
     name = "rarfile-${version}";
     version = "2.8";

     src = fetchPyPi {
       package = "rarfile";
       inherit version;
       sha256 = "2a27e401daa6d8ff0df1112a274a3661ca3e4afaac626217506fb1391069ca61";
     };

     meta = {
       description = "rarfile - RAR archive reader for Python";
       homepage = https://github.com/markokr/rarfile;
     };
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

   certifi = buildPythonPackage rec {
     name = "certifi-${version}";
     version = "2016.9.26";

     src = fetchPyPi {
       package = "certifi";
       inherit version;
       sha256 = "8275aef1bbeaf05c53715bfc5d8569bd1e04ca1e8e69608cc52bcaac2604eb19";
     };

     meta = {
       homepage = http://certifi.io/;
       description = "Python package for providing Mozilla's CA Bundle";
       license = licenses.isc;
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

   pytestrunner = buildPythonPackage rec {
     name = "pytest-runner-${version}";
     version = "2.9";

     src = fetchPyPi {
       package = "pytest-runner";
       inherit version;
       sha256 = "50378de59b02f51f64796d3904dfe71b9dc6f06d88fc6bfbd5c8e8366ae1d131";
     };

     buildInputs = with self; [setuptools-scm pytest];

     meta = {
       description = "Invoke py.test as distutils command with dependency resolution";
       homepage = https://bitbucket.org/pytest-dev/pytest-runner;
       license = licenses.mit;
     };

     # Trying to run tests fails with # RuntimeError: dictionary changed size during iteration
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

   functools32 = if isPy3k then null else buildPythonPackage rec {
     name = "functools32-${version}";
     version = "3.2.3-2";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/f/functools32/functools32-${version}.tar.gz";
       sha256 = "0v8ya0b58x47wp216n1zamimv4iw57cxz3xxhzix52jkw3xks9gn";
     };


     meta = with stdenv.lib; {
       description = "This is a backport of the functools standard library module from";
       homepage = "https://github.com/MiCHiLU/python-functools32";
     };
   };

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


   jsonschema = buildPythonPackage (rec {
     version = "2.5.1";
     name = "jsonschema-${version}";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/j/jsonschema/jsonschema-${version}.tar.gz";
       sha256 = "0hddbqjm4jq63y8jf44nswina1crjs16l9snb6m3vvgyg31klrrn";
     };

     buildInputs = with self; [ nose mock vcversioner ];
     propagatedBuildInputs = with self; [ functools32 ];

     patchPhase = ''
       substituteInPlace jsonschema/tests/test_jsonschema_test_suite.py --replace "python" "${python}/bin/${python.executable}"
    '';

     checkPhase = ''
       nosetests
     '';

     meta = {
       homepage = https://github.com/Julian/jsonschema;
       description = "An implementation of JSON Schema validation for Python";
       license = licenses.mit;
       maintainers = with maintainers; [ iElectric ];
     };
   });

   vcversioner = buildPythonPackage rec {
     name = "vcversioner-${version}";
     version = "2.16.0.0";
    src = fetchPyPi {
      package = "vcversioner";
      inherit version;
      sha256 = "dae60c17a479781f44a4010701833f1829140b1eeccd258762a74974aa06e19b";
     };

     meta = with stdenv.lib; {
       homepage = "https://github.com/habnabit/vcversioner";
     };
   };

   gevent = buildPythonPackage rec {
     name = "gevent-${version}";
     version = "1.1.2";

     src = fetchPyPi {
       package = "gevent";
       inherit version;
       sha256 = "cb15cf73d69a2eeefed330858f09634e2c50bf46da9f9e7635730fcfb872c02c";
     };

     prePatch = ''
       rm -rf libev
     '';

     buildInputs = [
       pkgs.libev
     ];
     propagatedBuildInputs = optionals (!isPyPy) [ self.greenlet ];


     meta = {
       description = "Coroutine-based networking library";
       homepage = http://www.gevent.org/;
       license = licenses.mit;
       platforms = platforms.all;
       maintainers = with maintainers; [ ];
     };
   };

   greenlet = buildPythonPackage rec {
     name = "greenlet-${version}";
     version = "0.4.10";
     disabled = isPyPy;  # builtin for pypy

     src = fetchPyPi {
       package = "greenlet";
       inherit version;
       sha256 = "c4417624aa88380cdf0fe110a8a6e0dbcc26f80887197fe5df0427dfa348ae62";
     };

     meta = {
       homepage = https://pypi.python.org/pypi/greenlet;
       description = "Module for lightweight in-process concurrent programming";
       license     = licenses.lgpl2;
       platforms   = platforms.all;
    };
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

   pylast = buildPythonPackage rec {
     name = "pylast-${version}";
     version = "1.6.0";

     src = fetchPyPi {
       package = "pylast";
       inherit version;
       sha256 = "6bf325ee0fdeb35780554843cf64df99304abb98c5ce2e451c0df7e95e08b42e";
     };

     propagatedBuildInputs = with self; [ six ];

     # error: invalid command 'test'

     meta = {
       homepage = http://code.google.com/p/pylast/;
       description = "A python interface to last.fm (and compatibles)";
       license = licenses.asl20;
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

   lxml = buildPythonPackage ( rec {
     name = "lxml-${version}";
     version = "3.6.4";

     src = fetchPyPi {
       package = "lxml";
       inherit version;
       sha256 = "61d5d3e00b5821e6cda099b3b4ccfea4527bf7c595e0fb3a7a760490cedd6172";
     };

     buildInputs = with self; [ pkgs.libxml2 pkgs.libxslt ];

     meta = {
       description = "Pythonic binding for the libxml2 and libxslt libraries";
       homepage = http://lxml.de;
       license = licenses.bsd3;
       maintainers = with maintainers; [ ];
     };
   });

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

   oauthlib = buildPythonPackage rec {
     name = "oauthlib-${version}";
       version = "2.0.0";

     src = fetchPyPi {
       package = "oauthlib";
       inherit version;
       sha256 = "0ad22b4f03fd75ef18d5793e1fed5e2361af5d374009f7722b4af390a0030dfd";
     };

     buildInputs = with self; optionals doCheck [ mock nose unittest2 ];

     propagatedBuildInputs = with self; [ cryptography pycrypto blinker pyjwt ];

     doCheck = false;

     meta = {
       homepage = https://github.com/idan/oauthlib;
       downloadPage = https://github.com/idan/oauthlib/releases;
       description = "A generic, spec-compliant, thorough implementation of the OAuth request-signing logic";
       maintainers = with maintainers; [ ];
     };
   };

   parsedatetime = buildPythonPackage rec {
     name = "parsedatetime-2.1";

     src = pkgs.fetchurl {
       url = "https://pypi.python.org/packages/source/p/parsedatetime/${name}.tar.gz";
       sha256 = "17c578775520c99131634e09cfca5a05ea9e1bd2a05cd06967ebece10df7af2d";
     };

   };

   paramiko = buildPythonPackage rec {
     name = "paramiko-${version}";
     version = "2.0.2";

     src = fetchPyPi {
       package = "paramiko";
       inherit version;
       sha256 = "411bf90fa22b078a923ff19ef9772c1115a0953702db93549a2848acefd141dc";
     };

     propagatedBuildInputs = with self; [ cryptography pyasn1 pycrypto ecdsa six ];

     meta = {
       homepage = "https://github.com/paramiko/paramiko/";
       description = "Native Python SSHv2 protocol library";
       license = licenses.lgpl21Plus;
       maintainers = with maintainers; [ aszlig ];
     };
   };

   pathpy = buildPythonPackage rec {
     version = "8.2.1";
     name = "path.py-${version}";

     src = fetchPyPi {
       package = "path.py";
       inherit version;
       sha256 = "c9ad2d462a7f8d7f6f6d2b89220bd50425221e399a4b8dfe5fa6725eb26fd708";
     };

     buildInputs = with self; [setuptools-scm pytestrunner pytest pkgs.glibcLocales ];

     LC_ALL="en_US.UTF-8";

     meta = {
       description = "A module wrapper for os.path";
       homepage = http://github.com/jaraco/path.py;
       license = licenses.mit;
     };

     checkPhase = ''
       py.test test_path.py
     '';
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

   pyacoustid = buildPythonPackage rec {
     name = "pyacoustid-${version}";
     version = "1.1.2";

     src = fetchPyPi {
       package = "pyacoustid";
       inherit version;
       sha256 = "e5f2990c12232807bd5c534e60b6b1955d8bc9ddade37473ae5aea9d890f2945";
     };

     propagatedBuildInputs = with self; [ requests audioread ];

     postPatch = ''
       sed -i \
           -e '/^FPCALC_COMMAND *=/s|=.*|= "${pkgs.chromaprint}/bin/fpcalc"|' \
           acoustid.py
     '';

     meta = {
       description = "Bindings for Chromaprint acoustic fingerprinting";
       homepage = "https://github.com/sampsyo/pyacoustid";
       license = licenses.mit;
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

     propagatedBuildInputs = with self; [ pycrypto ecdsa pytestrunner ];


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
     version = "1.5.3";

     src = fetchPyPi {
       package = "python-mimeparse";
       inherit version;
       sha256 = "ba91676c824648ec677eed9ea8b5ed370d404e25ef19ea42c3359c06e0bcfd72";
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

   unidecode = buildPythonPackage rec {
     name = "Unidecode-${version}";
     version = "0.04.19";

     src = fetchPyPi {
       package = "Unidecode";
       inherit version;
       sha256 = "51477646a9169469e37e791b13ae65fcc75b7f7f570d0d3e514d077805c02e1e";
     };

     LC_ALL="en_US.UTF-8";

     buildInputs = [ pkgs.glibcLocales ];

     meta = {
       homepage = https://pypi.python.org/pypi/Unidecode/;
       description = "ASCII transliterations of Unicode text";
       license = licenses.gpl2;
       maintainers = with maintainers; [ iElectric ];
     };
   };

}
