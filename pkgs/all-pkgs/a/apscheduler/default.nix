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

, pytest
}:

let
  inherit (lib)
    optionals;

  version = "3.5.1";
in
buildPythonPackage rec {
  name = "apscheduler-${version}";

  src = fetchPyPi {
    package = "APScheduler";
    inherit version;
    sha256 = "952c8f46a11f32b9d5bfbe3e347dac2cdf0680d8b4799590dc9c3a9865b73b65";
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
  ] ++ optionals (!isPy3) /* python 2 only */ [
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
