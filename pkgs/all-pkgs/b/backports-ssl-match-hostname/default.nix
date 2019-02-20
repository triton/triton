{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, pythonAtLeast
}:

let
  version = "3.7.0.1";
  currentImpl = "3.7";
in
buildPythonPackage rec {
  name = "backports-ssl-match-hostname-${version}";

  src = fetchPyPi {
    package = "backports.ssl_match_hostname";
    inherit version;
    sha256 = "bb82e60f9fbf4c080eabd957c39f0641f0fc247d9a16e31e26d594d8f42b9fd2";
  };

  # Backport of functionality from latest cpython changes.
  disabled = pythonAtLeast currentImpl;
  doCheck = true;

  passthru = {
    inherit currentImpl;
  };

  meta = with lib; {
    description = "The ssl.match_hostname() function from Python 3.5";
    homepage = http://bitbucket.org/brandon/backports.ssl_match_hostname;
    license = licenses.free; # python sfl
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
