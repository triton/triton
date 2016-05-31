{ stdenv
, buildPythonPackage
, config
, fetchPyPi
, pythonPackages

, apscheduler
, beautifulsoup
, cherrypy
, deluge
, feedparser
, flask
, flask-compress
, flask-cors
, flask-login
, flask-restful
, flask-restplus
, future
, guessit
, html5lib
, jinja2
, jsonschema
, pathlib
, pathpy
, pkgs
#, progressbar
, pynzb
, pyparsing
, pyrss2gen
, python-dateutil
, pyyaml
, requests2
, rpyc
, safe
, sqlalchemy
, transmissionrpc
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
  version = "2.0.37";

  src = fetchPyPi {
    package = "FlexGet";
    inherit version;
    sha256 = "8f9c5e53a2f4cf382b38c128229255bb7498fb9c9df8a113bdd2bc6ee39cd93f";
  };

  postPatch =
    /* Allow using newer dependencies */ ''
      sed -i requirements.txt \
        -e 's/, !=3.1.0//' \
        -e 's/flask-restplus==0.8.6/flask-restplus>=0.8.6/' \
        -e 's/guessit<=2.0.4/guessit>=2.0.4/'
    '';

  propagatedBuildInputs = [
    apscheduler
    beautifulsoup
    cherrypy
    feedparser
    flask
    flask-compress
    flask-cors
    flask-login
    flask-restful
    flask-restplus
    future
    guessit
    html5lib
    jinja2
    jsonschema
    pathpy
    #progressbar
    pynzb
    pyparsing
    pyrss2gen
    python-dateutil
    pyyaml
    requests2
    rpyc
    safe
    sqlalchemy

    #paver
    #python-tvrage
    #tmdb3
    transmissionrpc
  ] ++ optionals (pythonOlder "3.4") [
    pathlib
  ] ++ optionals (config.deluge or false) [
    deluge
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
