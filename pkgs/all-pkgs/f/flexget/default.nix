{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib
, pythonOlder

, apscheduler
, beautifulsoup
, cheroot
, cherrypy
, colorclass
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
, portend
#, progressbar
, pynzb
, pyparsing
, pyrss2gen
, python-dateutil
, pyyaml
, requests
, rpyc
, sqlalchemy
, terminaltables
, transmissionrpc
, zxcvbn-python
}:

let
  inherit (lib)
    optionals
    optionalString;

  version = "2.10.104";
in
buildPythonPackage rec {
  name = "flexget-${version}";

  src = fetchPyPi {
    package = "FlexGet";
    inherit version;
    sha256 = "ae600707556fa59f8eff8704da1557785eb3ddc74e4a78ab50795091dd199c15";
  };

  propagatedBuildInputs = [
    apscheduler
    beautifulsoup
    cheroot
    cherrypy
    colorclass
    deluge
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
    portend
    pynzb
    pyparsing
    pyrss2gen
    python-dateutil
    pyyaml
    requests
    rpyc
    sqlalchemy
    terminaltables
    transmissionrpc
    zxcvbn-python
  ] ++ optionals (pythonOlder "3.4") [
    pathlib
  ];

  postPatch = /* Allow using newer dependencies */ ''
    sed -i requirements.txt \
      -e 's/,.*<.*//' \
      -e 's/<.*//' \
      -e 's/!=.*//' \
      -e 's/==.*//'
  '' + /* Fix discover plugin not respecting limit */ ''
    sed -i flexget/plugins/input/discover.py \
      -e '/>\s500/,+2d'
  '';

  disabled = isPy3;

  meta = with lib; {
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
