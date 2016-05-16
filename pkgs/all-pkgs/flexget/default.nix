{ stdenv
, buildPythonPackage
, config
, fetchurl

, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
in

buildPythonPackage rec {
  name = "flexget-${version}";
  version = "2.0.22";

  src = fetchurl {
    url = "https://github.com/Flexget/Flexget/archive/${version}.tar.gz";
    sha256 = "0d7112ce7354e4f9d6c48f25d717e62db7c24b8397187b03cb868d5f5c08a251";
  };

  postPatch =
    /* Allow using newer apscheduler */ ''
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
    pythonPackages.pathlib
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
