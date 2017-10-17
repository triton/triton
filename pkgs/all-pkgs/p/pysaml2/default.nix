{ stdenv
, buildPythonPackage
, fetchPyPi

, decorator
, future
, paste
, pycryptodomex
, pyopenssl
, python-dateutil
, pytz
, repoze-who
, requests
, six
, zope-interface
}:

let
  version = "4.5.0";
in
buildPythonPackage {
  name = "pysaml2-${version}";

  src = fetchPyPi {
    package = "pysaml2";
    inherit version;
    sha256 = "59f82ee82390482640b298045a792455dae6cae580d8c0a3c935f0038f878133";
  };

  propagatedBuildInputs = [
    decorator
    future
    paste
    pycryptodomex
    pyopenssl
    python-dateutil
    pytz
    repoze-who
    requests
    six
    zope-interface
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
