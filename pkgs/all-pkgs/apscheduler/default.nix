{ stdenv
, buildPythonPackage
, fetchPyPi

, isPy3k
, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
in

buildPythonPackage rec {
  name = "apscheduler-${version}";
  version = "3.1.0";

  src = fetchPyPi {
    package = "APScheduler";
    inherit version;
    sha256 = "96a7ca40dbfb16502b44740c31c935943532f5a13be114e75419ca86fa264486";
  };

  buildInputs = [
    pythonPackages.enum34
    pythonPackages.pytz
    pythonPackages.setuptools
    pythonPackages.setuptools-scm
    pythonPackages.six
    pythonPackages.tzlocal
  ] ++ optionals (!isPy3k) /* python 2 only */ [
    pythonPackages.funcsigs
    pythonPackages.futures
  ];

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
