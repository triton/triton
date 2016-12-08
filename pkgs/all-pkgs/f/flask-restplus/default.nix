{ stdenv
, buildPythonPackage
, fetchPyPi

, aniso8601
, flask
, jsonschema
, pytz
, six

, blinker
, flask-restful
, mock
, nose
#, rednose
, tzlocal

, channel ? "0.9"
}:

let
  inherit (stdenv.lib)
    optionals
    versionOlder;

  sources = {
    "0.8" = {
      version = "0.8.6";
      sha256 = "3bb76cc156b9a09da62396d82b29fa31e4f27cccf79528538fe7155cf2785593";
    };
    "0.9" = {
      version = "0.9.2";
      sha256 = "c4313097a673ef2cffabceb44b6fdd03132ee5e7ab34d0289c37af12a3d11186";
    };
  };

  source = sources."${channel}";
in
buildPythonPackage rec {
  name = "flask-restplus-${source.version}";

  src = fetchPyPi {
    package = "flask-restplus";
    inherit (source) sha256 version;
  };

  propagatedBuildInputs = [
    aniso8601
    flask
    jsonschema
    pytz
    six
  ] ++ optionals (versionOlder source.version "0.9.0") [
    flask-restful
  ] ++ optionals doCheck [
    blinker
    mock
    nose
    #rednose
    tzlocal
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Framework for fast, easy and documented API development";
    homepage = https://github.com/noirbizarre/flask-restplus;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
