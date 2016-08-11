{ stdenv
, buildPythonPackage
, fetchPyPi
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
  inherit (stdenv.lib)
    optionals;
  inherit (pythonPackages)
    isPy3k
    pythonOlder;
in
buildPythonPackage rec {
  name = "apscheduler-${version}";
  version = "3.2.0";

  src = fetchPyPi {
    package = "APScheduler";
    inherit version;
    sha256 = "5baa1195ba711868fae257612cf80372ff1124014ca896884bf132f75636f638";
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

  meta = with stdenv.lib; {
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
