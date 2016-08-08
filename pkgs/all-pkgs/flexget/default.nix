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
, requests
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
  version = "2.2.11";

  src = fetchPyPi {
    package = "FlexGet";
    inherit version;
    sha256 = "c4dfcbb1cf983d5dec2a571bbe21c781cbb2720aa4d2275808c9c9cbeffc1ccd";
  };

  postPatch =
    /* Allow using newer dependencies */ ''
      sed -i requirements.txt \
        -e 's/,.*<.*//' \
        -e 's/<.*//' \
        -e 's/!=.*//' \
        -e 's/==.*//'
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
    requests
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
