{ stdenv
, buildPythonPackage
, config
, fetchPyPi

, pkgs
, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
  inherit (pythonPackages)
    isPy3k
    pythonOlder;
in

buildPythonPackage rec {
  name = "flexget-${version}";
  version = "2.0.24";

  src = fetchPyPi {
    package = "FlexGet";
    inherit version;
    sha256 = "ab03b63cab522ace9ab8cd59e9c98a72b9239d3b425187096b2289a46d5bcc56";
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
    #pythonPackages.progressbar
    pythonPackages.pynzb
    pythonPackages.pyparsing
    pythonPackages.pyrss2gen
    pythonPackages.python-dateutil
    pythonPackages.pyyaml
    pythonPackages.requests2
    pythonPackages.rpyc
    pythonPackages.safe
    pythonPackages.sqlalchemy

    #pythonPackages.paver
    #pythonPackages.python-tvrage
    #pythonPackages.tmdb3
    pythonPackages.transmissionrpc
  ] ++ optionals (pythonOlder "3.4") [
    pythonPackages.pathlib
  ] ++ optionals (config.pythonPackages.deluge or false) [
    pythonPackages.deluge
  ];

  disabled = isPy3k;
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
