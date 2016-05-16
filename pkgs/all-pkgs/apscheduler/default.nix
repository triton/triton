{ stdenv
, buildPythonPackage
, fetchPyPi

, isPy3k
, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
  inherit (pythonPackages)
    pythonOlder;
in

buildPythonPackage rec {
  name = "apscheduler-${version}";
  version = "3.1.0";

  src = fetchPyPi {
    package = "APScheduler";
    inherit version;
    sha256 = "96a7ca40dbfb16502b44740c31c935943532f5a13be114e75419ca86fa264486";
  };

  propagatedBuildInputs = [
    pythonPackages.pytz
    pythonPackages.setuptools
    pythonPackages.setuptools-scm
    pythonPackages.six
    pythonPackages.tzlocal
  ] ++ /* optional */ [
    /* executors */
    pythonPackages.gevent
    pythonPackages.tornado
    pythonPackages.twisted
    /* job stores */
    pythonPackages.pymongo
    pythonPackages.redis
    #pythonPackages.rethinkdb
    pythonPackages.sqlalchemy
  ] ++ optionals (!isPy3k) /* python 2 only */ [
    pythonPackages.funcsigs
    pythonPackages.futures
  ] ++ optionals (pythonOlder "3.4") [
    pythonPackages.enum34
  ] ++ optionals doCheck [
    pythonPackages.pytest
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
