{ stdenv
, buildPythonPackage
, config
, fetchurl

, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
  inherit (pythonPackages)
    pythonOlder;
in

buildPythonPackage rec {
  name = "flexget-${version}";
  version = "2.0.24";

  src = fetchurl {
    url = "https://github.com/Flexget/Flexget/archive/${version}.tar.gz";
    sha256 = "1afef61d2da1f4a8cca0bf13e3da80ebfee615afcf071902e7d836e2c6abf96f";
  };

  postPatch =
    /* Allow using newer dependencies */ ''
      sed -i requirements.txt \
        -e 's/, !=3.1.0//' \
        -e 's/flask-restplus==0.8.6/flask-restplus>=0.8.6/' \
        -e 's/guessit<=2.0.4/guessit>=2.0.4/'
    '';

  propagatedBuildInputs = [
    pythonPackages.apscheduler
    pythonPackages.beautifulsoup
    pythonPackages.cherrypy
    pythonPackages.feedparser
    pythonPackages.flask
    pythonPackages.flask-compress
    pythonPackages.flask-cors
    pythonPackages.flask-login
    pythonPackages.flask-restful
    pythonPackages.flask-restplus
    pythonPackages.future
    pythonPackages.guessit
    pythonPackages.html5lib
    pythonPackages.jinja2
    pythonPackages.jsonschema
    pythonPackages.pathpy
    pythonPackages.paver
    pythonPackages.progressbar
    pythonPackages.pynzb
    pythonPackages.pyparsing
    pythonPackages.pyrss2gen
    pythonPackages.python-dateutil
    pythonPackages.python-tvrage
    pythonPackages.pyyaml
    pythonPackages.requests2
    pythonPackages.rpyc
    pythonPackages.safe
    pythonPackages.sqlalchemy
    pythonPackages.tmdb3
    pythonPackages.transmissionrpc
  ] ++ optionals (pythonOlder "3.4") [
    pythonPackages.pathlib
  ] ++ optionals (config.pythonPackages.deluge or false) [
    pythonPackages.deluge
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Automation tool for content like torrents, nzbs, podcasts";
    homepage = http://flexget.com/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
