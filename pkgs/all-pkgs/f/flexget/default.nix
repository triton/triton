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

  version = "2.3.25";
in
buildPythonPackage rec {
  name = "flexget-${version}";

  src = fetchPyPi {
    package = "FlexGet";
    inherit version;
    sha256 = "6e25dfb50c94946f32f7fb020404f285fe37f387533c31668dbe25210bd66843";
  };

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

  postPatch =
    /* Allow using newer dependencies */ ''
      sed -i requirements.txt \
        -e 's/,.*<.*//' \
        -e 's/<.*//' \
        -e 's/!=.*//' \
        -e 's/==.*//'
    '';

    pipWhlFile = "*py3*";

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
