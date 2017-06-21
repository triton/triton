{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

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

, channel ? "latest"
}:

let
  inherit (lib)
    optionals
    versionOlder;

  sources = {
    "0.8" = {
      version = "0.8.6";
      sha256 = "3bb76cc156b9a09da62396d82b29fa31e4f27cccf79528538fe7155cf2785593";
    };
    "latest" = {
      version = "0.10.1";
      sha256 = "129767ba6087a6f0a6d1bd901f4c11192b4d33fe80c38cf2a8a0b5f8dd6049e3";
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

  meta = with lib; {
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
