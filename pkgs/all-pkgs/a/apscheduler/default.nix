{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3k
, lib
, pythonOlder
, pythonPackages

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

, pytest
}:

let
  inherit (lib)
    optionals;
in
buildPythonPackage rec {
  name = "apscheduler-${version}";
  version = "3.3.1";

  src = fetchPyPi {
    package = "APScheduler";
    inherit version;
    sha256 = "f68874dff1bdffcc6ce3adb7840c1e4d162c609a3e3f831351df30b75732767b";
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
    pymongo
    redis
    #rethinkdb
    sqlalchemy
  ] ++ optionals (!isPy3k) /* python 2 only */ [
    funcsigs
    futures
  ] ++ optionals (pythonOlder "3.4") [
    enum34
  ] ++ optionals doCheck [
    pytest
  ];

  # TODO: needs rethinkdb & QT4/5
  doCheck = false;

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
