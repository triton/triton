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
  version = "4.4.0";
in
buildPythonPackage {
  name = "pysaml2-${version}";

  src = fetchPyPi {
    package = "pysaml2";
    inherit version;
    sha256 = "a83768a873b905451b4931f242983ac95849d4c7ccefbe13119f301f6feadd5a";
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
