{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib
, pythonOlder

, enum34
, funcsigs
, futures
, gevent
, pymongo
, pytz
, redis
#, rethinkdb
, setuptools-scm
, six
, sqlalchemy
, tornado
, twisted
, tzlocal
}:

let
  inherit (lib)
    optionals;

  version = "3.6.0";
in
buildPythonPackage rec {
  name = "apscheduler-${version}";

  src = fetchPyPi {
    package = "APScheduler";
    inherit version;
    sha256 = "8f56b888fdc9dc57dd18d79c124b5093a01e29144be84e3e99130600eea34260";
  };

  propagatedBuildInputs = [
    pytz
    setuptools-scm
    six
    tzlocal
  ] ++ /* optional */ [
    /* executors */
    gevent
    tornado
    twisted
    /* job stores */
    #kazoo  # TODO: zookeeper
    pymongo
    redis
    #rethinkdb
    sqlalchemy
  ] ++ optionals (!isPy3) /* python 2 only */ [
    funcsigs
    futures
  ] ++ optionals (pythonOlder "3.4") [
    enum34
  ];

  meta = with lib; {
    description = "In-process task scheduler with Cron-like capabilities";
    homepage = https://github.com/agronholm/apscheduler/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
