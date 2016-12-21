{ stdenv
, buildPythonPackage
, config
, fetchPyPi
, isPy3k
, pythonOlder

, apscheduler
, beautifulsoup
, cherrypy
, colorclass
, deluge
, feedparser
, flask
, flask-compress
, flask-cors
, flask-login
, flask-restful
, flask-restplus_0-8
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
, terminaltables
, transmissionrpc
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  version = "2.8.8";
in
buildPythonPackage rec {
  name = "flexget-${version}";

  src = fetchPyPi {
    package = "FlexGet";
    inherit version;
    sha256 = "8588bfbea8d123743f6470bb2ea94c59a5f4de582ef79085969d63b83c5aa811";
  };

  propagatedBuildInputs = [
    apscheduler
    beautifulsoup
    cherrypy
    colorclass
    feedparser
    flask
    flask-compress
    flask-cors
    flask-login
    flask-restful
    flask-restplus_0-8
    future
    guessit
    html5lib
    jinja2
    jsonschema
    pathpy
    pynzb
    pyparsing
    pyrss2gen
    python-dateutil
    pyyaml
    requests
    rpyc
    safe
    sqlalchemy
    terminaltables
    transmissionrpc
  ] ++ optionals (pythonOlder "3.4") [
    pathlib
  ] ++ optionals (config.deluge or false) [
    deluge
  ];

  postPatch = /* Allow using newer dependencies */ ''
    sed -i requirements.txt \
      -e 's/,.*<.*//' \
      -e 's/<.*//' \
      -e 's/!=.*//' \
      -e 's/==.*//'
  '';

  disabled = isPy3k;

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
