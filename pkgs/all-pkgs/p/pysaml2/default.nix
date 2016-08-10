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
  version = "4.0.5";
in
buildPythonPackage {
  name = "pysaml2-${version}";

  src = fetchPyPi {
    package = "pysaml2";
    inherit version;
    sha256 = "2486ba2de001cf89823114f2d13a00dee8f1119553f7e8dee3750f5f50df2082";
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
